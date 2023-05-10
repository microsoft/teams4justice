# CaseRoomCreated

Code:
[src/shared/integration-events/case-room-created.event.ts](../../../src/shared/integration-events/case-room-created.event.ts)

## Description

The `CaseRoomCreated` event indicates that a `case` object has been created and stored in
the database. It contains information on the case room including its corresponding caseId, case name, roomType,
and case start and end times.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
case in the database during the [creation of a new hearing](../features/create-new-hearing.md).

## Receiving the event

The [case-room-created
function](../../../src/call-management-bot/case-room-created/case-room-created.handler.ts)
receives this event and creates an online meeting for the case room. It then
returns a [CaseRoomOnlineMeetingCreated](CaseRoomOnlineMeetingCreated.md) event
with the online meeting information

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
