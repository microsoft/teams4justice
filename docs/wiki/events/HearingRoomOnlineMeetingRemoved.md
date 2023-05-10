# HearingRoomOnlineMeetingRemoved

Code: [src/shared/integration-events/hearing-room-onlinemeeting-removed.event.ts](../../../src/shared/integration-events/hearing-room-onlinemeeting-removed.event.ts)

## Description

`HearingRoomOnlineMeetingRemoved` is returned by the Call Management Bot when an
online meeting for the hearing room has been removed.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             |                |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-room-removed function](../../../src/call-management-bot/hearing-room-removed/hearing-room-removed.handler.ts)
sends this event after it removes an online meeting for the hearing room.

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Cancel Hearing](../features/cancel-hearing.md)
