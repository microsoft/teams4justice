import { setConfig } from 'azure-ad-verify-token';
import { verify as verifyWithSigningKey, VerifyErrors } from 'jsonwebtoken';
import winston from 'winston';
import 'isomorphic-fetch';

type JWKS = {
  keys: JWK[];
};

type JWK = {
  alg: string;
  kty: string;
  use: string;
  n: string;
  e: string;
  kid: string;
  x5t: string;
  x5c: string[];
};

let configuredTokenVerificationOptions:
  | SignalRTokenVerificationOptions
  | undefined;

export interface SignalRTokenVerificationOptions {
  disabled?: boolean;
  audience: string;
  issuer: string;
  jwksUrl?: string;
  signingKey?: string;
}

export function readEnvironmentValueAndThrowIfMissing(
  environmentVariableName: string,
): string {
  const result = process.env[environmentVariableName];

  if (result === undefined || result.length === 0) {
    throw new Error(
      `Required environment variable is not set: ${environmentVariableName}`,
    );
  }

  return result;
}

export function getTokenVerificationOptions(): SignalRTokenVerificationOptions {
  if (configuredTokenVerificationOptions !== undefined) {
    return configuredTokenVerificationOptions;
  }

  const jwksCacheMinutes = parseInt(
    process.env.AZURE_AD_JWKS_CACHE_MINUTES ?? '30',
    10,
  );

  setConfig({ cacheLifetime: jwksCacheMinutes * 60 * 1000 });

  configuredTokenVerificationOptions = {
    audience: readEnvironmentValueAndThrowIfMissing(
      'AZURE_AD_REST_API_CLIENT_ID',
    ),
    issuer: readEnvironmentValueAndThrowIfMissing('AZURE_AD_ISSUER_URL'),
    jwksUrl: process.env.AZURE_AD_JWKS_URL,
    signingKey: process.env.AZURE_AD_AUTH_SIGNING_KEY,
    disabled: process.env.AZURE_AD_AUTH_DISABLED === 'true',
  };

  if (
    configuredTokenVerificationOptions?.disabled &&
    process.env.NODE_ENV !== 'Development'
  ) {
    throw new Error(
      // eslint-disable-next-line max-len
      `Authentication cannot be disabled in environments other than 'Development'; current environment detected as: ${process.env.NODE_ENV}`,
    );
  }

  return configuredTokenVerificationOptions;
}

export async function authorizeSignalRRequest(
  authorizationHeaderValue: string | undefined,
  tokenVerificationOptions: SignalRTokenVerificationOptions,
  logger: winston.Logger,
): Promise<boolean> {
  if (tokenVerificationOptions.disabled === true) {
    logger.warn(
      'Authentication is currently disabled, skipping any authentication.',
    );

    return true;
  }

  function decodeAndJsonParse<T>(base64: string): T {
    // Decode the JSON string from Base 64
    const json = Buffer.from(base64, 'base64').toString('ascii');
    // Return the parsed object
    return JSON.parse(json);
  }

  async function authorizeWithJwksUrl(jwt: string) {
    try {
      const [rawHead] = jwt.split('.');

      // Read the head section of the JWT into a known type
      const parsedHead =
        decodeAndJsonParse<{ alg: string; kid: string }>(rawHead);

      // Check that the alg property is the algorithm that was used to sign the token.
      if (parsedHead.alg !== 'RS256') {
        logger.error(
          `JWT verification failed using JWKS: Algorith that was used to sign the token isn't RS256`,
          {
            jwt,
            expectedAudience: tokenVerificationOptions.audience,
            expectedIssuer: tokenVerificationOptions.issuer,
            jwksUri: tokenVerificationOptions.jwksUrl,
          },
        );
        return false;
      }

      // Get the key
      const jwksResponse = await fetch(tokenVerificationOptions.jwksUrl!);

      // Read the JSON response as a JWKS type
      const jwks: JWKS = (await jwksResponse.json()) as JWKS;

      // Find the key that matches the token
      const jwk = jwks.keys.find((key) => key.kid === parsedHead.kid) as JWK;

      // Check that a key was found and that it's the correct algorithm
      if (jwk.kty !== 'RSA') {
        logger.error(
          `JWT verification failed using JWKS: JWK does not represent RSA keys`,
          {
            jwt,
            expectedAudience: tokenVerificationOptions.audience,
            expectedIssuer: tokenVerificationOptions.issuer,
            jwksUri: tokenVerificationOptions.jwksUrl,
          },
        );
        return false;
      }

      // await verifyWithJwks(jwt, {
      //   audience: tokenVerificationOptions.audience,
      //   issuer: tokenVerificationOptions.issuer,
      //   jwksUri: tokenVerificationOptions.jwksUrl!,
      // });

      return true;
    } catch (error) {
      logger.error(`JWT verification failed using JWKS: ${error}`, {
        jwt,
        expectedAudience: tokenVerificationOptions.audience,
        expectedIssuer: tokenVerificationOptions.issuer,
        jwksUri: tokenVerificationOptions.jwksUrl,
      });

      return false;
    }
  }

  function authorizeWithSigningKey(jwt: string) {
    try {
      verifyWithSigningKey(jwt, tokenVerificationOptions.signingKey!, {
        audience: tokenVerificationOptions.audience,
        issuer: tokenVerificationOptions.issuer,
      });
    } catch (verifyErrors) {
      logger.error(
        `JWT verification failed using signing key: ${
          (verifyErrors as VerifyErrors).message
        }`,
        {
          jwt,
          expectedAudience: tokenVerificationOptions.audience,
          expectedIssuer: tokenVerificationOptions.issuer,
          signingKey: tokenVerificationOptions.signingKey,
        },
      );

      return false;
    }

    return true;
  }

  if (authorizationHeaderValue === undefined) {
    throw new Error('No Authorization header found, cannot be verified!');
  }

  const authorizationHeaderValueParts = authorizationHeaderValue.split(' ', 2);

  if (authorizationHeaderValueParts.length !== 2) {
    throw new Error('Expected a Bearer JWT in the Authorization header.');
  }

  const [bearerPrefix, jwt] = authorizationHeaderValueParts;

  if (bearerPrefix.toUpperCase() !== 'BEARER') {
    throw new Error('Expected a Bearer JWT in the Authorization header.');
  }

  if (tokenVerificationOptions.jwksUrl !== undefined) {
    return authorizeWithJwksUrl(jwt);
  }

  if (tokenVerificationOptions.signingKey !== undefined) {
    return authorizeWithSigningKey(jwt);
  }

  throw new Error('Neither jwksUri or signingKey set in options.');
}
