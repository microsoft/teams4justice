# Trade Study: Hearing Room Participants Source Of Truth

|                 |                                                                     |
| --------------: | ------------------------------------------------------------------- |
| _Conducted by:_ | Azadeh Khojandi                                                     |
|  _Sprint Name:_ | 15                                                                  |
|         _Date:_ | 29/07/2021                                                          |
|     _Decision:_ | Cosmos DB will be the source of truth for hearing room participants |

## Overview

To manage the court hearings, the participants need to be placed in different
rooms accordingly. In the system, we have two types of rooms **solo rooms** and
**party rooms**. For example, **defendants** are displayed under **Defendant
room** which is a **party room** and **witnesses** are displayed under the
**witnesses room** which is a **solo type**; each witness resides in a separate
team meeting until they get invited to the hearing meeting room by the
moderator.

The court moderators would like to have a real-time view of which room each
participant is located in.

## Goals

- Agreeing on the source of truth to demonstrate participants in each room

## Open questions

1. What options do we have to get participants in each room?
2. What are the pros and cons of each option?

## Solutions

To get Participants present in each teams meeting room (party rooms, solo rooms)
there are two options to consider:

1. Calling [Mircosoft Graph
   Api](https://docs.microsoft.com/en-us/graph/api/onlinemeeting-get?view=graph-rest-1.0&tabs=http)

2. Subscribing to the `User Added/Removed Event` received from the Call
   Management Bots residing in each teams meeting room and save it in the
   cosomos db.

### Solution 1 - Microsoft Graph API

Get Particpants present in each teams meeting room by providing [meeting
ID](https://docs.microsoft.com/en-us/graph/api/onlinemeeting-get?view=graph-rest-1.0&tabs=http#example-2-retrieve-an-online-meeting-by-meeting-id)
or [join web
url](https://docs.microsoft.com/en-us/graph/api/onlinemeeting-get?view=graph-rest-1.0&tabs=http#example-3-retrieve-an-online-meeting-by-joinweburl)

#### Pros

- Low implementation effort, the graph API is available to call
- Cost-effective, no need to pay for storage and compute to track & store
  hearing participant's location
- True representation of people in the room

#### Cons

- [Throttling](https://docs.microsoft.com/en-us/graph/throttling#microsoft-teams-service-limits),
  any Graph API calls for Microsoft Teams has a limit of 15000 requests every 10
  seconds per app per tenant
- Doesn't follow Event-driven architecture. If it's added to the API project, it
  introduces dependency to the Microsoft Graph API and breaks the separation of
  concerns.

### Solution 2 - Event Subscribing and Cosmos DB

Subscribing to the `User Added/Removed Event` received from the Call Management
Bots residing in each teams meeting room. Storing the data in the Cosmos DB
(Add/Update `hearingRoomParticipant` entity)

#### Pros

- Cache
- Audit log participant movements **[out of scope]**
- Reporting **[out of scope]**
- Follows Event-driven architecture

#### Cons

- Cosmos DB RU cost for Create and Update `hearingRoomParticipant`
- Multiple points of failures (Call Management Bot, Publisher, Subscriber)
- Implementation effort

### Decision

After discussing the options we all agreed to go with **Solution 2 - Event
Subscribing and Cosmos DB**.

- Product Owners; Janine Zhu & David McGhee; Accepted the risk of implementation
  may affect our timeline.
- Product Owners; Janine Zhu & David McGhee; Accepted the cost associated with
  this approach.
- Omeed Musavi, Drew Marsh & Team; Will provide event contract and implement
  User Added/Removed Event in the Call Management Bot
- Quokka Crew, will implement subscribing to the event, persisting the
  participant's current location in Cosmos DB.
