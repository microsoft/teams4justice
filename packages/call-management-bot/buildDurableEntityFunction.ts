import { defaultLogger } from '@tfj/shared/logging';
import * as appInsights from 'applicationinsights';
import { azureFunctionsTypes } from 'applicationinsights';
import * as df from 'durable-functions';
import { IEntityFunctionContext } from 'durable-functions/lib/src/ientityfunctioncontext';
import winston from 'winston';
import createLoggerForEntityContext from './entity-context-logger';

const durableEntityFunctionLogger = defaultLogger.child({
  context: 'Call Management Bot Entity',
});

export type DurableEntityFunction<TState> = (
  context: IEntityFunctionContext<TState>,
  logger: winston.Logger,
) => Promise<void>;

export default function buildDurableEntityFunction<TState>(
  entityFunction: DurableEntityFunction<TState>,
) {
  return df.entity<TState>(async (context) => {
    const appInsightsFunctionCorrelationContext = appInsights.startOperation(
      context as azureFunctionsTypes.Context,
      `${context.df.entityName}::${context.df.operationName}`,
    )!;

    return appInsights.wrapWithCorrelationContext(async () => {
      const entityOperationSpecificLogger = createLoggerForEntityContext(
        durableEntityFunctionLogger,
        context,
      );

      try {
        await entityFunction(context, entityOperationSpecificLogger);
      } catch (error) {
        if (error instanceof Error) {
          entityOperationSpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred while executing operation '${context.df.operationName}': ${error.message}\r\n\r\n${error.stack}`,
          );
        } else {
          entityOperationSpecificLogger.error(
            // eslint-disable-next-line max-len
            `An unhandled error occurred while executing operation '${context.df.operationName}': ${error}`,
          );
        }

        throw error;
      }
    }, appInsightsFunctionCorrelationContext)();
  });
}
