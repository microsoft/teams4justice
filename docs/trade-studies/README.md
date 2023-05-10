# Trade Studies

A [trade study](https://mechanicalc.com/reference/trade-study) is a term used in development to make an
[architectural decision](https://adr.github.io/) record.

Also known as a trade-off analysis, it is a method for making a decision between competing alternatives.

The primary steps of a formal trade study are:

- Identify alternatives
- Select criteria
- Assign criteria weights
- Rate performance
- Calculate results

## Documentation

| Page                                                                         | Description                                                                                         |
| :--------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------- |
| [Calender](./calendar-component.md)                                          | Decisions on the calender component choice                                                          |
| [Code generation](./code-generation.md)                                      | Client side code generation to make REST requests                                                   |
| [Deployment](./deployment-trade-study.md)                                    | How to deploy the solution to Azure                                                                 |
| [Generate Event Model From Schema](./generate-event-model-from-schema.md)    | A shared library where all the Event models are stored                                              |
| [Get User Details](./get-user-details.md)                                    | Service account extract the details of users invited to a hearing                                   |
| [Participant Source](./hearing-participants-source-of-truth.md)              | Source for real-time view of which room each participant is located in                              |
| [Sending messages](./meeting-room-broadcast-technical-design.md)             | Ability for the moderator to send a message to an existing meeting room                             |
| [Get Participant Details](./participant-photo-technical-design.md)           | Extracting participant details from the Microsoft Graph API to be surfaced on the UI layer          |
| [Realtime meeting room update](./realtime-view-of-rooms-and-participants.md) | get the latest view of the meeting room when it has been updated                                    |
| [Participant entity design](./room-participant-entity-design.md)             | Schematic changes for party and solo room entities in the database                                  |
| [Solo room entity design](./solo-room-entity-design.md)                      | Schematic changes for party and solo room entities betwen bot and rooms                             |
| [Trade study template](./trade-study-template.md)                            | Template design for further trade studies                                                           |
| [Vaidation](./validation.md)                                                 | Validation is needed to inspect and ensure that any incoming request to the API contains valid data |
