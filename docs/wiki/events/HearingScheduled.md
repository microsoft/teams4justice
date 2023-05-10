# HearingScheduled

Code: [src/shared/integration-events/hearing-scheduled.event.ts](../../../src/shared/integration-events/hearing-scheduled.event.ts)

> Note: "event" here is overloaded a little bit by our Event Grid events, and the MS Graph Calendar events API. If the
> bare word "event" is used in this documentation, assume an event grid event. All Graph Calendar Events will be called
> out as "calendar event"

## Description

`HearingScheduled` indicates that a hearing has been scheduled by the user and a `hearing` object has been written to
the database. The case level reception room online meeting must also exist before this event fires.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
`hearing` if there is an existing case in the database during the [creation of a new hearing](../features/create-new-hearing.md).

## Receiving the event

The [hearing-scheduled function](../../../src/call-management-bot/hearing-scheduled/hearing-scheduled.handler.ts) receives
this event and creates a calendar event for the hearing. The calendar event must include the Teams "Join" link to the
Reception Room.

The function then returns a [HearingCalendarEventCreated](HearingCalendarEventCreated.md)
event with the calendar event information

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
