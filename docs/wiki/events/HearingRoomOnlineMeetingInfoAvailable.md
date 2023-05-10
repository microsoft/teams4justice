# HearingRoomOnlineMeetingInfoAvailable

Code:
[src/shared/integration-events/hearing-room-onlinemeeting-info-available.event.ts](../../../src/shared/integration-events/hearing-room-onlinemeeting-info-available.event.ts)

## Description

The `HearingRoomOnlineMeetingInfoAvailable` event indicates that the `hearing` object in the database has been updated
with the online meeting information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             |                |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/events/room-online-meeting-created.eventhandler.ts) after it has
updated the hearing room with the meeting info it received from the [previous event](HearingRoomOnlineMeetingCreated.md)

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
