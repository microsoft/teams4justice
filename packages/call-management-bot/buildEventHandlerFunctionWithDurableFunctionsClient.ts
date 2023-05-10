import { buildEventHandlerFunction } from '@tfj/shared/integration-events';
import { defaultLogger } from '@tfj/shared/logging';
import EventBase from '@tfj/shared/integration-events/event-base';
import { EventGridEvent } from '@azure/eventgrid';
import { Context } from '@azure/functions';
import * as df from 'durable-functions';
import { DurableOrchestrationClient } from 'durable-functions/lib/src/durableorchestrationclient';
import * as winston from 'winston';

export default function buildEventHandlerFunctionWithDurableFunctionsClient<
  TInputEvent extends EventBase,
  TOutput extends unknown | void = void,
>(
  expectedEventTypes: string | string[],
  handler: (
    eventGridEvent: EventGridEvent<TInputEvent>,
    logger: winston.Logger,
    durableClient: DurableOrchestrationClient,
  ) => Promise<TOutput | void>,
) {
  let wrappedHandler: (
    eventGridEvent: EventGridEvent<TInputEvent>,
    logger: winston.Logger,
  ) => Promise<TOutput | void>;

  let eventNameTester: (eventTypeName: string) => boolean;

  const innerEventHandlerFunction = buildEventHandlerFunction<
    TInputEvent,
    TOutput
  >(expectedEventTypes, async (eventGridEvent, logger) =>
    wrappedHandler(eventGridEvent, logger),
  );

  if (typeof expectedEventTypes === 'string') {
    eventNameTester = (eventTypeName) => eventTypeName === expectedEventTypes;
  } else {
    eventNameTester = (eventTypeName) =>
      expectedEventTypes.includes(eventTypeName);
  }

  defaultLogger.debug(
    `Executing durable client event handler(s): ${eventNameTester}...`,
  );

  return async (
    context: Context,
    eventGridEvent: EventGridEvent<TInputEvent>,
  ) => {
    wrappedHandler = async (ege, l) => handler(ege, l, df.getClient(context));

    return await innerEventHandlerFunction(context, eventGridEvent);
  };
}
