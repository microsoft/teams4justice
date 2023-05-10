# HearingEdited

Code: [src/shared/integration-events/hearing-edited.event.ts](../../../src/shared/integration-events/hearing-edited.event.ts)

> Note: "event" here is overloaded a little bit by our Event Grid events, and the MS Graph Calendar events API. If the
> bare word "event" is used in this documentation, assume an event grid event. All Graph Calendar Events will be called
> out as "calendar event"

## Description

`HearingEdited` indicates that a scheduled hearing has been edited by the user and a `hearing` object has been updated
to the database. The case level online meeting must also exist before this event fires.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/edit-hearing.commandhandler.ts) after it has edited the
`hearing` if there is a change to the hearing the changes the event ie. date, invitees, subject, body during the
[modification of an exiting hearing](../features/edit-hearing.md).

## Receiving the event

The [hearing-edited function](../../../src/call-management-bot/hearing-edited/hearing-edited.handler.ts) receives
this event and updated the calendar event for the hearing.

The function then returns a [HearingEventInfoChanged](HearingEventInfoChanged.md)
event with the calendar event information

## Event Flows

- [Edit Hearing](../features/edit-hearing.md)
