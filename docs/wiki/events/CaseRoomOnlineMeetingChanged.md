# CaseRoomOnlineMeetingChanged

Code:
[src/shared/integration-events/case-room-onlinemeeting-changed.event.ts](../../../src/shared/integration-events/case-room-onlinemeeting-changed.event.ts)

## Description

The `CaseRoomOnlineMeetingChanged` event indicates that the subject for the online meeting was changed for an
existing meeting.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             |                |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [case-room-onlinemeeting-subject-changed function](../../../src/call-management-bot/case-room-onlinemeeting-subject-changed/case-room-onlinemeeting-subject-changed.handler.ts)
sends this event after it updates an online meeting for the case room.

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
- [Create Hearing](../features/create-new-hearing.md)
