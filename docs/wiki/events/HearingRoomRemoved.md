# HearingRoomRemoved

Code:
[src/shared/integration-events/hearing-room-removed.event.ts](../../../src/shared/integration-events/hearing-room-removed.event.ts)

## Description

The `HearingRoomRemoved` event indicates that a `hearingRoom` object has been removed and stored in the database as Inactive.
It contains information on the hearing room including its name, ID, and onlineMeetingId.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/cancel-hearing.commandhandler.ts) after it has cancelled
a hearing. The cancelled hearing logic will update the `hearingRoom` in the database during the
[cancellation of a new hearing](../features/cancel-hearing.md).

The API will send this event multiple times, one for each active hearing room when a hearing is cancelled.

## Receiving the event

The [hearing-room-removed function](../../../src/call-management-bot/hearing-room-removed/hearing-room-removed.handler.ts)
receives this event and removes the online meeting for the hearing room. It then returns a
[HearingRoomOnlineMeetingRemoved](HearingRoomOnlineMeetingRemoved.md) event .

## Event Flows

- [Cancel Hearing](../features/cancel-hearing.md)
