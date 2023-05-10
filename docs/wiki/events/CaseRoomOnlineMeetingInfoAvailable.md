# CaseRoomOnlineMeetingInfoAvailable

Code:
[src/shared/integration-events/case-room-onlinemeeting-info-available.event.ts](../../../src/shared/integration-events/case-room-onlinemeeting-info-available.event.ts)

## Description

The `CaseRoomOnlineMeetingInfoAvailable` event indicates that the `case` object in the database has been
updated with the online meeting information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             |                |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/events/edit-case-room-online-meeting.eventhandler.ts) after it has
updated the case with the online meeting info it received from the [previous event](CaseRoomOnlineMeetingCreated.md)

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
