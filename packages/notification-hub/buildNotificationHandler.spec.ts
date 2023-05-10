import { Context } from '@azure/functions';
import { v4 as uuid } from 'uuid';
import { UnexpectedEventTypeError } from '@tfj/shared/integration-events';
import buildNotificationHandler from './buildNotificationHandler';

describe('buildNotificationHandler', () => {
  let testFunctionContext: Context;

  beforeEach(() => {
    testFunctionContext = {
      traceId: uuid(),
      bindings: {
        messages: [],
      },
      done: () => {},
    } as any as Context;
  });

  describe('build', () => {
    it('should return function - single event types', () => {
      const eventHandler = buildNotificationHandler('testEvent', () => []);

      expect(eventHandler).toBeInstanceOf(Function);
    });

    it('should return function - multiple event types', () => {
      const eventHandler = buildNotificationHandler(
        ['testEventA', 'testEventB', 'testEventC'],
        () => [],
      );

      expect(eventHandler).toBeInstanceOf(Function);
    });
  });

  describe('execute', () => {
    it('should invoke passed handler function', () => {
      const handler = jest.fn(() => []);

      const eventHandler = buildNotificationHandler('testEvent', handler);

      eventHandler(testFunctionContext, {
        id: uuid(),
        eventType: 'testEvent',
        eventTime: new Date(Date.now()),
        subject: 'subject',
        data: { correlationId: uuid() },
        dataVersion: 'v1',
      });

      expect(handler).toHaveBeenCalled();
    });

    it("throws if event doesn't match expected event type", () => {
      const eventHandler = buildNotificationHandler('testEvent', () => []);

      expect(() =>
        eventHandler(testFunctionContext, {
          id: uuid(),
          eventType: 'testEvent-UNEXPECTED',
          eventTime: new Date(Date.now()),
          subject: 'subject',
          data: { correlationId: uuid() },
          dataVersion: 'v1',
        }),
      ).toThrow(UnexpectedEventTypeError);
    });

    it("throws if event doesn't match one of the expected event types", () => {
      const eventHandler = buildNotificationHandler(
        ['testEventA', 'testEventB', 'testEventC'],
        () => [],
      );

      expect(() =>
        eventHandler(testFunctionContext, {
          id: uuid(),
          eventType: 'testEvent-UNEXPECTED',
          eventTime: new Date(Date.now()),
          subject: 'subject',
          data: { correlationId: uuid() },
          dataVersion: 'v1',
        }),
      ).toThrow(UnexpectedEventTypeError);
    });

    it('should return the result of the handler function', () => {
      const testResult = [
        {
          target: 'test',
          arguments: [],
        },
      ];

      const eventHandler = buildNotificationHandler(
        'testEvent',
        () => testResult,
      );

      eventHandler(testFunctionContext, {
        id: uuid(),
        eventType: 'testEvent',
        eventTime: new Date(Date.now()),
        subject: 'subject',
        data: { correlationId: uuid() },
        dataVersion: 'v1',
      });

      expect(testFunctionContext.bindings.messages).toBe(testResult);
    });
  });
});
