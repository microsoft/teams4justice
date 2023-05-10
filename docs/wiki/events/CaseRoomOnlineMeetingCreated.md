# CaseRoomOnlineMeetingCreated

Code:
[src/shared/integration-events/case-room-onlinemeeting-created.event.ts](../../../src/shared/integration-events/case-room-onlinemeeting-created.event.ts)

## Description

`CaseRoomOnlineMeetingCreated` is returned by the Call Management Bot when an online meeting for the case room has been
created. It contains the online meeting information for case room.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [case-room-created function](../../../src/call-management-bot/case-room-created/case-room-created.handler.ts) sends this
event after it creates an online meeting for the case.

## Receiving the event

The API [receives this
event](../../../src/api/events/incoming-integration-event-processing/converters/case-room-onlinemeeting-created.converter.ts)
and updates the database with the online meeting information in the
[`EditCaseRoomOnlineMeetingEventHandler`](../../../src/api/handlers/events/edit-case-room-online-meeting.eventhandler.ts)

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
