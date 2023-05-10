import * as jwt from 'jsonwebtoken';
import { v4 as uuid } from 'uuid';
import * as winston from 'winston';
import {
  authorizeSignalRRequest,
  SignalRTokenVerificationOptions,
} from './authentication';

describe('Call Notifications Request Authorization', () => {
  const testLogger = winston.createLogger({
    transports: [new winston.transports.Console()],
  });

  const testCallsNotificationTokenVerificationOptions: SignalRTokenVerificationOptions =
    {
      audience: `urn:test-audience/${uuid()}`,
      issuer: `urn:test-issuer/${uuid()}`,
      signingKey: uuid(),
    };

  it('should skip authentication if explicitly disabled', async () => {
    await expect(
      authorizeSignalRRequest(
        undefined,
        {
          disabled: true,
          ...testCallsNotificationTokenVerificationOptions,
        },
        testLogger,
      ),
    ).resolves.toBe(true);
  });

  it('should throw if no header value provided', async () => {
    await expect(
      authorizeSignalRRequest(
        undefined,
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).rejects.toThrow();
  });

  it('should throw if not a bearer token', async () => {
    await expect(
      authorizeSignalRRequest(
        'NotABearer 1234',
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).rejects.toThrow();
  });

  it('should return false if empty JWT', async () => {
    await expect(
      authorizeSignalRRequest(
        'Bearer ',
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).resolves.toBe(false);
  });

  it('should return false if invalid JWT', async () => {
    await expect(
      authorizeSignalRRequest(
        'Bearer not-a-jwt',
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).resolves.toBe(false);
  });

  it('show return false if JWT expired', async () => {
    await expect(
      authorizeSignalRRequest(
        `Bearer ${jwt.sign(
          {
            iss: testCallsNotificationTokenVerificationOptions.issuer,
            aud: testCallsNotificationTokenVerificationOptions.audience,
            iat: Math.floor(Date.now() / 1000 - 600),
            exp: Math.floor(Date.now() / 1000 - 300),
          },
          testCallsNotificationTokenVerificationOptions.signingKey!,
        )}`,
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).resolves.toBe(false);
  });

  it('show return true if JWT valid', async () => {
    await expect(
      authorizeSignalRRequest(
        `Bearer ${jwt.sign(
          {
            iss: testCallsNotificationTokenVerificationOptions.issuer,
            aud: testCallsNotificationTokenVerificationOptions.audience,
            iat: Math.floor(Date.now() / 1000),
            exp: Math.floor(Date.now() / 1000 + 300),
          },
          testCallsNotificationTokenVerificationOptions.signingKey!,
        )}`,
        testCallsNotificationTokenVerificationOptions,
        testLogger,
      ),
    ).resolves.toBe(true);
  });
});
