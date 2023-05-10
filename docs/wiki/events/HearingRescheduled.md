# HearingRescheduled

Code: [src/shared/integration-events/hearing-rescheduled.event.ts](../../../src/shared/integration-events/hearing-rescheduled.event.ts)

## Description

`HearingRescheduled` indicates that a scheduled hearing has been edited by the user and a `hearing` object has been updated
to the database. The case level online meeting must also exist before this event fires.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/edit-hearing.commandhandler.ts) after it has edited the
`hearing` if there is a change to the hearing the changes the start or end dates during the
[modification of an exiting hearing](../features/edit-hearing.md).

## Receiving the event

The Call Management Bot will receive this event and update its internal state to reflect the new schedule.

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
