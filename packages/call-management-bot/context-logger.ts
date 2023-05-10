import { Context } from '@azure/functions';
import { Logger } from 'winston';

export default function createLoggerForContext(
  parentLogger: Logger,
  context: Context,
  options?: Object,
) {
  const functionOptions = {
    function_invocationId: context.invocationId,
  };

  const finalOptions =
    options !== undefined
      ? { ...options, ...functionOptions }
      : functionOptions;

  const logger = parentLogger.child(finalOptions);

  return logger;
}
