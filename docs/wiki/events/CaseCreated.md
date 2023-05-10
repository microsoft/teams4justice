# CaseCreated

Code:
[src/shared/integration-events/case-created.event.ts](../../../src/shared/integration-events/case-created.event.ts)

## Description

The `CaseCreated` event indicates that a `case` object has been created and stored in
the database. It contains information on the case room including its corresponding caseId, roomType,
and case start and end times.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
`Case` entity in the database during the [creation of a new `Hearing`](../features/create-new-hearing.md).

## Receiving the event

### Call Management Bot

The bot receives this event and uses it to track its own state about online meetings as they relate to `Case`s.

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
- [Consistent Join - Reception Room Participant Routing](../features/consistent-join.md#reception-room-participant-routing)
