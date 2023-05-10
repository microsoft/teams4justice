# HearingRoomCreated

Code:
[src/shared/integration-events/hearing-room-created.event.ts](../../../src/shared/integration-events/hearing-room-created.event.ts)

## Description

The `HearingRoomCreated` event indicates that a `hearingRoom` object has been created and stored in the database. It contains
information on the hearing room including its name, ID, and start and end times.

Hearing Rooms are not meant to be persisted between scheduled hearings, unlike case rooms.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
`hearingRoom` in the database during the [creation of a new hearing](../features/create-new-hearing.md).

The API will send this event multiple times, one for each default hearing room when the hearing is created.

## Receiving the event

The [hearing-room-created function](../../../src/call-management-bot/hearing-room-created/hearing-room-created.handler.ts)
receives this event and creates an online meeting for the hearing room. It then returns a
[HearingRoomOnlineMeetingCreated](HearingRoomOnlineMeetingCreated.md) event with the online meeting information

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
