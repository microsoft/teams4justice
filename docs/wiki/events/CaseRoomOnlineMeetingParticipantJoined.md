# CaseRoomOnlineMeetingParticipantJoined

Code:
[src/shared/integration-events/case-room-participation-changed.event.ts](../../../src/shared/integration-events/case-room-participation-changed.event.ts)

## Description

`CaseRoomOnlineMeetingParticipantJoined` is published by the Call Management Bot when it receives a notification that a
new participant has joined a case room. It contains case, case room, and participant information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          | ✅             |
| Notification Hub    |             |                |

## Sending the event

The [`call-management-entity` function](../../../src/call-management-bot/call-management-entity/index.ts) sends this event
after determining the list of any new participants for a case room.

## Receiving the event

The API will receive this event so it can update the participant list in the Arena View UI.

The Call Management Bot will receive this event when someone joins the Reception room so that it can proceed with
identifying & transferring them accordingly.

The Call Management Bot will also receive this event when someone joins the Case Room so it can detect if the the
participant was successfully routed within a configured amount of time.

> NOTE: in the MVP if the participant fails to show up within the expected amount of time we will simply log a warning.
> Future logic might want to raise a specific event indicating that the routing of the participant failed so that some
> other part of the system could, for example, update the status of the participant to be "lost" and/or alert a
> moderator in some way.

## Event Flows

DNE
