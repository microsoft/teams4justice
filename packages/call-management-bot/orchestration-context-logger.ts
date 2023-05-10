import { IOrchestrationFunctionContext } from 'durable-functions/lib/src/classes';
import { LeveledLogMethod, Logger, LogMethod } from 'winston/';

function patchLogger(
  logger: Logger,
  orchestrationFunctionContext: IOrchestrationFunctionContext,
) {
  // Replace each of the level specific log methods first (e.g. info, warn, error, etc.)
  // NOTE: we have to do this because they actually bypass the base log method in cases where only a message is passed
  Object.keys(logger.levels).forEach((level) => {
    const originalLeveledLogFunction = (logger as unknown as any)[
      level
    ] as Function;

    // eslint-disable-next-line no-param-reassign
    (logger as unknown as any)[level] = <LeveledLogMethod>(
      function replayAwareLevelLogger(this: Logger, ...args: any[]) {
        if (orchestrationFunctionContext.df.isReplaying) {
          return this;
        }

        return originalLeveledLogFunction.apply(this, args);
      }
    );
  });

  // Replace the base most log function as well since that can also be called directly
  const originalLogFunction = logger.log as Function;

  // eslint-disable-next-line no-param-reassign
  logger.log = <LogMethod>(
    function replayAwareLogger(this: Logger, ...args: any[]) {
      // If the context is still replaying, we don't want to actually log anything
      if (orchestrationFunctionContext.df.isReplaying) {
        return this;
      }

      // The context is no longer replaying, call the original log method
      return originalLogFunction.apply(this, args);
    }
  );
}

export default function createLoggerForOrchestrationContext(
  parentLogger: Logger,
  orchestrationFunctionContext: IOrchestrationFunctionContext,
  options?: Object,
) {
  const orchestratorOptions = {
    orchestration_invocationId: orchestrationFunctionContext.invocationId,
    orchestration_instanceId: orchestrationFunctionContext.df.instanceId,
    orchestration_parentInstanceId:
      orchestrationFunctionContext.df.parentInstanceId,
  };

  const finalOptions =
    options !== undefined
      ? { ...options, ...orchestratorOptions }
      : orchestratorOptions;

  const logger = parentLogger.child(finalOptions);

  patchLogger(logger, orchestrationFunctionContext);

  return logger;
}
