# CaseRoomOnlineMeetingDurationChanged

Code:
[src/shared/integration-events/case-room-onlinemeeting-duration-changed.event.ts](../../../src/shared/integration-events/case-room-onlinemeeting-duration-changed.event.ts)

## Description

The `CaseRoomOnlineMeetingDurationChanged` event indicates that a new hearing was created for an existing case and the
`case` object in the database has been modified to contain the new start and end times, where the start time is the
earliest start of the hearings and the end of the last end of the hearings.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             |                |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has update the
`case` in the database during the [creation of a subsequent
hearing](../features/create-new-hearing.md#subsequent-hearings-for-a-case).

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
- [Edit Hearing](./README.md#edit-hearing)
