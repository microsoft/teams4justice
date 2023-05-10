import { UnexpectedEventTypeError } from '@tfj/shared/integration-events';
import { defaultLogger } from '@tfj/shared/logging';
import { EventGridEvent } from '@azure/eventgrid';
import { Context } from '@azure/functions';
import * as appInsights from 'applicationinsights';
import winston from 'winston';
import { azureFunctionsTypes } from 'applicationinsights';

const notificationHandlerLogger = defaultLogger.child({
  context: 'Notification Hub',
});

export type SignalRMessage = {
  target: string;
  arguments: any[];
};
export type EventHandlerFunction<TInputEvent> = (
  logger: winston.Logger,
  eventGridEvent: EventGridEvent<TInputEvent>,
) => SignalRMessage[];

export default function buildNotificationHandler<TInputEvent>(
  expectedEventTypeName: string | string[],
  eventHandler: EventHandlerFunction<TInputEvent>,
) {
  let eventNameTester: (eventTypeName: string) => boolean;
  let handlerLoggerContext: string;

  if (typeof expectedEventTypeName === 'string') {
    eventNameTester = (eventTypeName) =>
      eventTypeName === expectedEventTypeName;
    handlerLoggerContext = `eventHandler-${expectedEventTypeName}`;
  } else {
    eventNameTester = (eventTypeName) =>
      expectedEventTypeName.includes(eventTypeName);
    handlerLoggerContext = `eventHandler-[${expectedEventTypeName.join('|')}]`;
  }

  defaultLogger.debug(`Building event handler: ${handlerLoggerContext}...`);

  return (context: Context, eventGridEvent: EventGridEvent<TInputEvent>) => {
    const appInsightsFunctionCorrelationContext = appInsights.startOperation(
      context as azureFunctionsTypes.Context,
      handlerLoggerContext as string,
    )!;

    return appInsights.wrapWithCorrelationContext(() => {
      const eventSpecificLogger = notificationHandlerLogger.child({
        eventGridEventId: eventGridEvent.id,
        eventGridEventType: eventGridEvent.eventType,
        eventGridSubject: eventGridEvent.subject,
      });

      const eventLogDetails =
        `id=${eventGridEvent.id};` +
        `type=${eventGridEvent.eventType};subject=${eventGridEvent.subject}`;
      eventSpecificLogger.info(`Event Grid Event Received: ${eventLogDetails}`);

      if (!eventNameTester(eventGridEvent.eventType)) {
        throw new UnexpectedEventTypeError(
          expectedEventTypeName,
          eventGridEvent.eventType,
        );
      }

      try {
        const messages = eventHandler(eventSpecificLogger, eventGridEvent);
        context.bindings.messages = messages;
        context.done();
      } catch (error) {
        if (error instanceof Error) {
          eventSpecificLogger.error(
            `An unhandled error occurred: ${error.message}\r\n\r\n${error.stack}`,
          );
        } else {
          eventSpecificLogger.error(`An unhandled error occurred: ${error}`);
        }

        throw error;
      }
    }, appInsightsFunctionCorrelationContext)();
  };
}
