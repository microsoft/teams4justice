# SoloRoomRemoved

Code:
[src/shared/integration-events/solo-room-removed.event.ts](../../../src/shared/integration-events/solo-room-removed.event.ts)

## Description

The `SoloRoomRemoved` event indicates that a `soloRoom` object has been removed and stored in the database as Inactive.
It contains information on the solo room including its name and ID.

|                     | Sends Event | Receives Event       |
| ------------------- | ----------- | -------------------- |
| API                 | ✅          |                      |
| Call Management Bot |             | ✅ (Not implemented) |
| Notification Hub    |             |                      |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/cancel-hearing.commandhandler.ts) after it has cancelled
a hearing. The cancelled hearing logic will update the `soloRoom` in the database during the
[cancellation of a hearing](../features/cancel-hearing.md).

The API will send this event multiple times, one for each active solo room when a hearing is cancelled.

## Receiving the event

This has not been implemented yet.

## Event Flows

- [Cancel Hearing](../features/cancel-hearing.md)
