import { defaultLogger } from '@tfj/shared/logging';
import { Context } from '@azure/functions';
import * as appInsights from 'applicationinsights';
import winston from 'winston';
import createLoggerForContext from './context-logger';
import { azureFunctionsTypes } from 'applicationinsights';

export type DurableActivityFunction<TParams, TResult = void> = (
  context: Context,
  logger: winston.Logger,
  activityParams: TParams,
) => Promise<TResult>;

export default function buildDurableActivityFunction<TParams, TResult>(
  activityFunction: DurableActivityFunction<TParams, TResult>,
) {
  if (activityFunction.name.length === 0) {
    throw new Error('Activity functions must be named for telemetry purposes.');
  }

  defaultLogger.debug(
    `Building durable activity function: ${activityFunction.name}...`,
  );

  return async (context: Context, activityParams: TParams) => {
    const appInsightsFunctionCorrelationContext = appInsights.startOperation(
      context as azureFunctionsTypes.Context,
      activityFunction.name as string,
    )!;

    return appInsights.wrapWithCorrelationContext(async () => {
      const activitySpecificLogger = createLoggerForContext(
        defaultLogger,
        context,
      );

      try {
        return await activityFunction(
          context,
          activitySpecificLogger,
          activityParams,
        );
      } catch (error) {
        if (error instanceof Error) {
          activitySpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred while executing activity: ${error.message}\r\n\r\n${error.stack}`,
          );
        } else {
          activitySpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred while executing activity: ${error}`,
          );
        }

        throw error;
      }
    }, appInsightsFunctionCorrelationContext)();
  };
}
