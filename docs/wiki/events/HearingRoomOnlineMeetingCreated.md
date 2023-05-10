# HearingRoomOnlineMeetingCreated

Code: [src/shared/integration-events/hearing-room-onlinemeeting-created.event.ts](../../../src/shared/integration-events/hearing-room-onlinemeeting-created.event.ts)

## Description

`HearingRoomOnlineMeetingCreated` is returned by the Call Management Bot when an
online meeting for the hearing room has been created. It contains the online
meeting information for hearing room.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-room-created function](../../../src/call-management-bot/hearing-room-created/hearing-room-created.handler.ts)
sends this event after it creates an online meeting for the hearing room.

## Receiving the event

The API [receives this
event](../../../src/api/events/incoming-integration-event-processing/converters/hearing-room-onlinemeeting-created.converter.ts)
and updates the database with the online meeting information in the
[`EditHearingRoomOnlineMeetingEventHandler`](../../../src/api/handlers/events/room-online-meeting-created.eventhandler.ts)

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
