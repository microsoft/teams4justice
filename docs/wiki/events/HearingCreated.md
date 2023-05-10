# HearingCreated

Code:
[src/shared/integration-events/hearing-created.event.ts](../../../src/shared/integration-events/hearing-room-created.event.ts)

## Description

The `HearingCreated` event indicates that a `Hearing` entity has been created and stored in the database.

|                     | Sends Event | Receives Event |
| ------------------- | ----------- | -------------- |
| API                 | ✅          |                |
| Call Management Bot |             | ✅             |
| Notification Hub    |             |                |

## Sending the event

The API [sends this event](../../../src/api/handlers/commands/create-hearing.commandhandler.ts) after it has created the
`Hearing` entity in the database during the [creation of a new `Hearing`](../features/create-new-hearing.md).

## Receiving the event

### Call Management Bot

The bot receives this event and uses it to track its own state about online meetings as they relate to `Hearing`s.

The [add-external-invitees function](../../../src/call-management-bot/add-external-invitees/add-external-invitees.handler.ts)
receives this event, is used to add non-tenant participants to Azure Active Directory. No return value.

## Event Flows

- [Create New Hearing](./README.md#creating-a-new-hearing)
