# HearingRoomOnlineMeetingChanged

Code:
[src/shared/integration-events/hearing-room-onlinemeeting-changed.event.ts](../../../src/shared/integration-events/hearing-room-onlinemeeting-changed.event.ts)

## Description

The `HearingRoomOnlineMeetingChanged` event is returned by the Call Management
Bot when an online meeting for the hearing room has changed.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             |                |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-room-onlinemeeting-subject-changed function](../../../src/call-management-bot/hearing-room-onlinemeeting-subject-changed/hearing-room-onlinemeeting-subject-changed.handler.ts)
sends this event after it updates an online meeting for the hearing room.

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
