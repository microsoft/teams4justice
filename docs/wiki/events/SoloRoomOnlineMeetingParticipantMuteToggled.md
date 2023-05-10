# SoloRoomOnlineMeetingParticipantMuteToggled

Code:
[src/shared/integration-events/solo-room-participation-changed.event.ts](../../../src/shared/integration-events/solo-room-participation-changed.event.ts)

## Description

`SoloRoomOnlineMeetingParticipantMuteToggled` is published by the Call Management Bot when it receives a notification
that a participant's mute state has been toggled either by themselves or by a moderator. It contains case, case room,
and participant information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [`call-management-entity` function](../../../src/call-management-bot/call-management-entity/index.ts) sends this
event when it receives a call notification from Teams/Graph that relates to a Solo Room, performs its delta logic and
detects that a participant's mute state has changed.

## Receiving the event

The API will receive this event so it can update the participant list in the Hearing Control UI.

## Event Flows

DNE
