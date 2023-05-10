import { defaultLogger } from '@tfj/shared/logging';
import * as appInsights from 'applicationinsights';
import { azureFunctionsTypes } from 'applicationinsights';
import * as df from 'durable-functions';
import { Task, TaskSet } from 'durable-functions/lib/src/classes';
import { IOrchestrationFunctionContext } from 'durable-functions/lib/src/iorchestrationfunctioncontext';
import winston from 'winston';
import createLoggerForOrchestrationContext from './orchestration-context-logger';

export type DurableOrchestratorFunction = (
  context: IOrchestrationFunctionContext,
  logger: winston.Logger,
) => Generator<Task | TaskSet, void, unknown>;

export default function buildDurableOrchestratorFunction(
  orchestratorFunction: DurableOrchestratorFunction,
) {
  // eslint-disable-next-line func-names
  return df.orchestrator(function* (context) {
    const appInsightsFunctionCorrelationContext = appInsights.startOperation(
      context as azureFunctionsTypes.Context,
      `${orchestratorFunction.name}::${context.df.instanceId}`,
    )!;

    const orchestrationLogger = createLoggerForOrchestrationContext(
      defaultLogger,
      context,
    );

    const orchestrationGenerator = orchestratorFunction(
      context,
      orchestrationLogger,
    );

    let nextTask = appInsights.wrapWithCorrelationContext(
      () => orchestrationGenerator.next(),
      appInsightsFunctionCorrelationContext,
    )();

    do {
      const nextTaskValue = nextTask.value;

      yield nextTaskValue;

      if (nextTask.done === true) {
        break;
      }

      nextTask = appInsights.wrapWithCorrelationContext(
        // eslint-disable-next-line @typescript-eslint/no-loop-func
        () => orchestrationGenerator.next(nextTaskValue!.result),
        appInsightsFunctionCorrelationContext,
      )();
    } while (true);
  });
}
