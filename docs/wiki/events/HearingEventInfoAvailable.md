# HearingEventInfoAvailableEvent

Code:
[src/shared/integration-events/hearing-event-info-available.event.ts](../../../src/shared/integration-events/hearing-event-info-available.event.ts)

## Description

The `HearingEventInfoAvailableEvent` event indicates that the `hearing` object in the database has been updated with the
calendar event information.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             |                |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/events/edit-hearing-event.eventhandler.ts) after it has
updated the hearing with the calendar event info it received from the [previous event](HearingCalendarEventCreated.md)

## Receiving the event

_Currently nothing listens to this event._

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
