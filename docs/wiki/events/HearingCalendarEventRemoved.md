# HearingCalendarEventRemoved

Code: [src/shared/integration-events/hearing-calendar-event-removed.event.ts](../../../src/shared/integration-events/hearing-calendar-event-removed.event.ts)

> Note: "event" here is overloaded a little bit by our Event Grid events, and the MS Graph Calendar events API. If the
> bare word "event" is used in this documentation, assume an event grid event. All Graph Calendar Events will be called
> out as "calendar event"

## Description

`HearingCalendarEventRemoved` is returned by the Call Management Bot when a calendar event for the hearing has been removed.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             |                |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-cancelled
function](../../../src/call-management-bot/hearing-cancelled/hearing-cancelled.handler.ts)
sends this event after it removes a calendar event for this hearing.

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Cancel Hearing](../features/cancel-hearing.md)
