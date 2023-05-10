# HearingCancelled

Code: [src/shared/integration-events/hearing-cancelled.event.ts](../../../src/shared/integration-events/hearing-cancelled.event.ts)

> Note: "event" here is overloaded a little bit by our Event Grid events, and the MS Graph Calendar events API. If the
> bare word "event" is used in this documentation, assume an event grid event. All Graph Calendar Events will be called
> out as "calendar event"

## Description

`HearingCancelled` indicates that a hearing has been cancelled by the user and a `hearing` object has updated to
the database.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/cancel-hearing.commandhandler.ts) after it has cancelled
the `hearing`.

## Receiving the event

The [hearing-cancelled function](../../../src/call-management-bot/hearing-cancelled/hearing-cancelled.handler.ts) receives
this event and removed the calendar event for the hearing.

The function then returns a [HearingCalendarEventRemoved](HearingCalendarEventRemoved.md)
event with the calendar event information

## Event Flows

- [Cancel Hearing](../features/cancel-hearing.md)
