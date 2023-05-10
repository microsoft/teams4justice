# CaseRoomOnlineMeetingSubjectChanged

Code:
[src/shared/integration-events/case-room-onlinemeeting-subject-changed.event.ts](../../../src/shared/integration-events/case-room-onlinemeeting-subject-changed.event.ts)

## Description

The `CaseRoomOnlineMeetingSubjectChanged` event indicates that the subject for the online meeting was changed for an
existing meeting.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/edit-hearing.commandhandler.ts) if it detects a change to
the case room subject during the [update of a hearing hearing](../features/edit-hearing.md).
The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) if it detects a change to
the case room subject during the [creation of a subsequent hearing of an existing case](../features/create-new-hearing.md).

## Receiving the event

The [case-room-onlinemeeting-subject-changed function](../../../src/call-management-bot/case-room-onlinemeeting-subject-changed/case-room-onlinemeeting-subject-changed.handler.ts)
receives this event and updates the online meeting. It then returns a [CaseRoomOnlineMeetingChanged](CaseRoomOnlineMeetingChanged.md)
event with the online meeting information

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
- [Create Hearing](../features/create-new-hearing.md)
