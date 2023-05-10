# SoloRoomCreated

Code:
[src/shared/integration-events/solo-room-created.event.ts](../../../src/shared/integration-events/solo-room-created.event.ts)

## Description

The `SoloRoomCreated` event indicates that a `soloRoom` object has been created and stored in the database. It contains
information on the solo room including its name, ID, and start and end times. Unlink a hearing room, there are multiple
room online meetings linked to a solo room using the attribute `roomId`.

Solo Rooms do not actually cause an online meeting to be created, unlike hearing rooms. The room online meetings entity
along with an online meeting will be created when a matching participant party being reassigned into this room.

|                     | Sends Event | Receives Event       |
| ------------------- | ----------- | -------------------- |
| API                 | ✅          |                      |
| Call Management Bot |             | ✅ (Not implemented) |
| Notification Hub    |             |                      |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
`soloRoom` in the database during the [creation of a new hearing](../features/create-new-hearing.md).

The API will send this event multiple times, one for each default solo room when the hearing is created. Examples of
default solo rooms are: lobby, defendant witnesses, plaintiff witnesses.

## Receiving the event

This has not been implemented yet.

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
