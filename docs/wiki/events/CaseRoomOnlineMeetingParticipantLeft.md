# CaseRoomOnlineMeetingParticipantLeft

Code:
[src/shared/integration-events/case-room-participation-changed.event.ts](../../../src/shared/integration-events/case-room-participation-changed.event.ts)

## Description

`CaseRoomOnlineMeetingParticipantLeft` is published by the Call Management Bot when it receives a notification that an
existing participant has left a case room. It contains case, case room, and participant information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          | ✅             |
| Notification Hub    |             |                |

## Sending the event

The [`call-management-entity` function](../../../src/call-management-bot/call-management-entity/index.ts) sends this event
after determining the list of removed participants from a case room.

## Receiving the event

The API will receive this event so it can update the participant list in the Arena View UI.

The Call Management Bot will receive this event so it can determine if the removal of a participant from a case room was
successful.

## Event Flows

DNE
