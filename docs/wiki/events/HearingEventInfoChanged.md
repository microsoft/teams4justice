# HearingEventInfoChangedEvent

Code:
[src/shared/integration-events/hearing-event-info-changed.event.ts](../../../src/shared/integration-events/hearing-event-info-changed.event.ts)

## Description

The `HearingEventInfoChangedEvent` is returned by the Call Management Bot when a calendar event has been updated.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             |                |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-edited function](../../../src/call-management-bot/hearing-edited/hearing-edited.handler.ts) sends this event
after it updates a calendar event for this hearing.

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
