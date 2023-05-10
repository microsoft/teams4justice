import { IEntityFunctionContext } from 'durable-functions/lib/src/classes';
import { Logger } from 'winston';

export default function createLoggerForEntityContext<TEntity>(
  parentLogger: Logger,
  entityFunctionContext: IEntityFunctionContext<TEntity>,
  options?: Object,
) {
  const { df: durableEntityContext } = entityFunctionContext;

  const entityOptions = {
    context: durableEntityContext.entityName,
    entity_entityId: `${durableEntityContext.entityName}::${durableEntityContext.entityKey}`,
    entity_operationName: durableEntityContext.operationName,
    entity_invocationId: entityFunctionContext.invocationId,
    entity_isNewlyConstructed: durableEntityContext.isNewlyConstructed,
  };

  const finalOptions =
    options !== undefined ? { ...options, ...entityOptions } : entityOptions;

  const logger = parentLogger.child(finalOptions);

  return logger;
}
