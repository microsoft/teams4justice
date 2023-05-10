# HearingCalendarEventCreated

Code: [src/shared/integration-events/hearing-calendar-event-created.event.ts](../../../src/shared/integration-events/hearing-calendar-event-created.event.ts)

> Note: "event" here is overloaded a little bit by our Event Grid events, and the MS Graph Calendar events API. If the
> bare word "event" is used in this documentation, assume an event grid event. All Graph Calendar Events will be called
> out as "calendar event"

## Description

`HearingCalendarEventCreated` is returned by the Call Management Bot when a calendar event for the hearing has been created
and the emails have been sent. It includes information of the calendar event including the iCalUId.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 |             | ✅             |
| Call Management Bot | ✅          |                |
| Notification Hub    |             |                |

## Sending the event

The [hearing-schedule
function](../../../src/call-management-bot/hearing-scheduled/hearing-scheduled.handler.ts)
sends this event after it creates a calendar event for this hearing.

## Receiving the event

The API [receives this
event](../../../src/api/events/incoming-integration-event-processing/converters/hearing-calendar-event-created.converter.ts)
and updates the database with the calendar event information in
[`EditHearingEventEventHandler`](../../../src/api/handlers/events/edit-hearing-event.eventhandler.ts)

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
