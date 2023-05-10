# HearingRoomOnlineMeetingSubjectChanged

Code:
[src/shared/integration-events/hearing-room-onlinemeeting-subject-changed.event.ts](../../../src/shared/integration-events/hearing-room-onlinemeeting-subject-changed.event.ts)

## Description

The `HearingRoomOnlineMeetingSubjectChanged` event indicates that the subject for the online meeting was changed for an
existing meeting.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/edit-hearing.commandhandler.ts) if it detects a change to
the hearing room subject during the [update of a hearing hearing](../features/edit-hearing.md).

## Receiving the event

The [hearing-room-onlinemeeting-subject-changed function](../../../src/call-management-bot/hearing-room-onlinemeeting-subject-changed/hearing-room-onlinemeeting-subject-changed.handler.ts)
receives this event and updates the online meeting. It then returns a [HearingRoomOnlineMeetingChanged](HearingRoomOnlineMeetingChanged.md)
event with the online meeting information

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
