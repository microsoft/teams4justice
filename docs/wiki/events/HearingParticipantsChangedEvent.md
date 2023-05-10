# HearingParticipantsChangedEvent

Code:
[src/shared/integration-events/hearing-participants-changed.event.ts](../../../src/shared/integration-events/hearing-participants-changed.event.ts)

## Description

The `HearingParticipantsChangedEvent` event indicates that the list of participants in a hearing was changed for an
existing hearing.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/edit-hearing.commandhandler.ts) if it detects a change to
the list of hearing participants during the [update of a hearing hearing](../features/edit-hearing.md). This includes
adding new participant(s), removing existing participant(s), and updating existing participant(s).

## Receiving the event

The [hearing-participants-changed function](../../../src/call-management-bot/hearing-participants-changed/hearing-participants-changed.handler.ts)
receives this event and sends an invite to any new participants which have been added.

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
