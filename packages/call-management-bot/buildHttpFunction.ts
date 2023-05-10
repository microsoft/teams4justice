import { defaultLogger } from '@tfj/shared/logging';
import { Context, HttpRequest } from '@azure/functions';
import * as appInsights from 'applicationinsights';
import winston from 'winston';
import createLoggerForContext from './context-logger';
import { azureFunctionsTypes } from 'applicationinsights';

const httpFunctionLogger = defaultLogger.child({
  context: 'Call Management Bot Http',
});

export type HttpFunction = (
  context: Context,
  logger: winston.Logger,
  httpRequest: HttpRequest,
) => Promise<void>;

export default function buildHttpFunction(httpFunction: HttpFunction) {
  return async (context: Context, httpRequest: HttpRequest) => {
    const appInsightsFunctionCorrelationContext = appInsights.startOperation(
      context as azureFunctionsTypes.Context,
      `${context.req?.method} ${context.req?.url} handler`,
    )!;

    return appInsights.wrapWithCorrelationContext(async () => {
      const httpRequestSpecificLogger = createLoggerForContext(
        httpFunctionLogger,
        context,
      );

      try {
        await httpFunction(context, httpRequestSpecificLogger, httpRequest);
      } catch (error) {
        if (error instanceof Error) {
          httpRequestSpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred: ${error.message}\r\n\r\n${error.stack}`,
          );
        } else {
          httpRequestSpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred: ${error}`,
          );
        }

        throw error;
      }
    }, appInsightsFunctionCorrelationContext)();
  };
}
