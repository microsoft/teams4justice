# Solution Architecture

## General principles

This solution presents a simple architecture that is well known to scale and is a cost effective option for customers.

It employs an event driven architecture and the following application domains:

1. UI
2. Courtroom API
3. Integration Handlers
4. Database

![Solution Architecture](./high-level-solution-architecture.png)

### UI

The solution is fronted as a single React application that will be hosted in an Azure App Service. We will be using the
[Fluent UI Northstar library](https://fluentsite.z22.web.core.windows.net/) to have a consistent Microsoft Teams-like experience.

**Note**: The primary experience is for the moderator who will, by in large, be using the Microsoft Teams desktop client.

### Call Management Events Flow

The Call Management represents the heart of the solution as it is responsible
for managing all aspects of the application events flow. The following diagram
depicts the user interactive event driven flow events:

![~Call Management Flow~](./call-management-flow.svg)

<details>
  <summary>Mermaid markup</summary>

```mermaid
sequenceDiagram %% diagram
  autonumber
  %% participant
  participant User
  participant CaseHandler as CaseCreatedHandler
  participant HearingHandler as HearingCreatedHandler
  participant RoomHandler as HearingRoomCreatedHandler
  participant caseCreatedOperation
  participant hearingCreatedOperation
  participant hearingRoomCreatedOperation
  participant RoomCreatedHandler
  participant GraphNotification
  participant OnlineOrchestration as HearingRoomOrchestration
  participant OnlineOrchestration2 as ReceptionRoomOrchestration
  participant KeepAliveOrchestration
  participant JoinOnlineMeetingActivity
  participant updateRoomStateWithCallInformationActivity
  participant ParticipantJoinedHandler
  participant participantJoinedReceptionRoomOperation
  participant MoveParticipantFunction
  participant DurableState as CaseCallTrackingState
  participant EventGrid
  participant GraphClient
  %% Flow

  activate User
  activate DurableState
  activate EventGrid
  %% Case Created
  Note over CaseHandler,caseCreatedOperation: New Case
  User->>EventGrid: CaseCreated
  EventGrid-->>+CaseHandler: CaseCreated
  CaseHandler->>+caseCreatedOperation: caseCreated
  caseCreatedOperation--x-CaseHandler: newState(caseDetails, {}, [])
  CaseHandler--x-DurableState: SaveState(CaseCallTrackingState)
  %% Hearing Created
  Note over HearingHandler,hearingCreatedOperation: New Hearing
  User->>EventGrid: HearingCreated
  EventGrid-->>+HearingHandler: HearingCreated
  DurableState-->>HearingHandler: retrieveState
  HearingHandler->>+hearingCreatedOperation: (hearingCreated, CaseCallTrackingState)
  hearingCreatedOperation--x-HearingHandler: newState(caseDetails, rooms, hearing, [])
  HearingHandler--x-DurableState: SaveState(CaseCallTrackingState)
  %% Hearing Room Created
  Note over RoomHandler,hearingRoomCreatedOperation: New Hearing Room
  User->>EventGrid: HearingRoomCreated
  par [Create Hearing Room Online Meeting]
  Note over RoomHandler, DurableState: Create Hearing Room Online Meeting
  EventGrid-->>+RoomHandler: HearingRoomCreated
  DurableState-->>RoomHandler: retrieveState
  RoomHandler->>+hearingRoomCreatedOperation: (hearingRoomCreated, CaseCallTrackingState)
  hearingRoomCreatedOperation->>DurableState: getHearingById(hearingId, CaseCallTrackingState)
  DurableState-->>hearingRoomCreatedOperation: hearing
  hearingRoomCreatedOperation->>+GraphClient: createOnlineMeeting(data)
  GraphClient--x-hearingRoomCreatedOperation: joinWebUrl
  hearingRoomCreatedOperation--x-RoomHandler: newState(caseDetails, rooms, hearing, hearingRooms)
  RoomHandler--x-DurableState: SaveState(CaseCallTrackingState)
  %% Online Lifecycle Orchestration
  and [Start Online Lifecycle Orchestration]
  Note over RoomCreatedHandler, OnlineOrchestration: Start Online Lifecycle Orchestration
  EventGrid-->>+RoomCreatedHandler: HearingRoomCreated
  RoomCreatedHandler-x-OnlineOrchestration: startNewOrchestration('onlineMeetingLifecycleManagement', roomDetails)
      loop Wait for External Event
          OnlineOrchestration->>OnlineOrchestration: roomOnlineMeetingInfoAvailable
      end
      loop Wait for Timer to Expire
          OnlineOrchestration->>OnlineOrchestration: meetingStartTimerTask
      end
      Note over OnlineOrchestration, GraphClient: Join Online Meeting
      OnlineOrchestration->>+JoinOnlineMeetingActivity: callActivityWithRetry(joinOnlineMeeting, joinWebUrl)
      JoinOnlineMeetingActivity->>+GraphClient: getOnlineMeeting(joinWebUrl)
      GraphClient--x-JoinOnlineMeetingActivity: onlineMeetingDetails
      JoinOnlineMeetingActivity->>+GraphClient: joinOnlineMeeting(onlineMeetingDetails)
      GraphClient--x-JoinOnlineMeetingActivity: call
      JoinOnlineMeetingActivity--x-OnlineOrchestration: call
      OnlineOrchestration->>+updateRoomStateWithCallInformationActivity: callActivityWithRetry(roomDetails, call)
      updateRoomStateWithCallInformationActivity->>DurableState: SaveState(roomDetails, call)
      OnlineOrchestration->>+KeepAliveOrchestration: keepAlive(call)
      loop Every 15 minutes
          KeepAliveOrchestration->>GraphClient: keepAlive(call)
      end
  end
  %% Reception Room Created
  Note over RoomHandler,hearingRoomCreatedOperation: New Reception Room
  User->>EventGrid: HearingRoomCreated
  par [Create Reception Room Online Meeting]
  Note over RoomHandler, DurableState: Create Reception Room Online Meeting
  EventGrid-->>+RoomHandler: HearingRoomCreated
  DurableState-->>RoomHandler: retrieveState
  RoomHandler->>+hearingRoomCreatedOperation: (hearingRoomCreated, CaseCallTrackingState)
  hearingRoomCreatedOperation->>DurableState: getHearingById(hearingId, CaseCallTrackingState)
  DurableState-->>hearingRoomCreatedOperation: hearing
  hearingRoomCreatedOperation->>+GraphClient: createOnlineMeeting(data)
  GraphClient--x-hearingRoomCreatedOperation: joinWebUrl
  hearingRoomCreatedOperation--x-RoomHandler: newState(caseDetails, rooms, hearing, hearingRooms)
  RoomHandler--x-DurableState: SaveState(CaseCallTrackingState)
  %% Online Lifecycle Orchestration
  and [Start Online Lifecycle Orchestration]
  Note over RoomCreatedHandler, OnlineOrchestration2: Start Online Lifecycle Orchestration
  EventGrid-->>+RoomCreatedHandler: HearingRoomCreated
  RoomCreatedHandler-x-OnlineOrchestration2: startNewOrchestration('onlineMeetingLifecycleManagement', roomDetails)
      loop Wait for External Event
          OnlineOrchestration2->>OnlineOrchestration2: roomOnlineMeetingInfoAvailable
      end
      loop Wait for Timer to Expire
          OnlineOrchestration2->>OnlineOrchestration2: meetingStartTimerTask
      end
      Note over OnlineOrchestration2, GraphClient: Join Online Meeting
      OnlineOrchestration2->>+JoinOnlineMeetingActivity: callActivityWithRetry(joinOnlineMeeting, joinWebUrl)
      JoinOnlineMeetingActivity->>+GraphClient: getOnlineMeeting(joinWebUrl)
      GraphClient--x-JoinOnlineMeetingActivity: onlineMeetingDetails
      JoinOnlineMeetingActivity->>+GraphClient: joinOnlineMeeting(onlineMeetingDetails)
      GraphClient--x-JoinOnlineMeetingActivity: call
      JoinOnlineMeetingActivity--x-OnlineOrchestration2: call
      OnlineOrchestration2->>+updateRoomStateWithCallInformationActivity: callActivityWithRetry(roomDetails, call)
      updateRoomStateWithCallInformationActivity->>DurableState: SaveState(roomDetails, call)
      OnlineOrchestration2->>+KeepAliveOrchestration: keepAlive(call)
      loop Every 15 minutes
          KeepAliveOrchestration->>GraphClient: keepAlive(call)
      end
  end
  User->>+GraphClient: Join Reception Room
  GraphClient--x-EventGrid: AddParticipant Event
  EventGrid--x+GraphNotification: AddParticipant
  GraphNotification-x-EventGrid: CaseRoomOnlineMeetingParticipantJoined
  EventGrid--x+ParticipantJoinedHandler: caseRoomOnlineMeetingParticipantJoined
  ParticipantJoinedHandler->>+participantJoinedReceptionRoomOperation: participantJoinedReceptionRoomOperation(CaseCallTrackingState, OnlineMeetingParticipationChanged)
  participantJoinedReceptionRoomOperation->>DurableState: getActiveHearing(state)
  DurableState--xparticipantJoinedReceptionRoomOperation: hearing
  participantJoinedReceptionRoomOperation--xparticipantJoinedReceptionRoomOperation: resolvedHearingParticipant()
  participantJoinedReceptionRoomOperation->>+MoveParticipantFunction: moveOnlineMeetingParticipantToHearingRoom(hearingParticipant, hearingRoom)
  MoveParticipantFunction->>+GraphClient: inviteParticipantsToMeeting(participantInvite)
  GraphClient--x-MoveParticipantFunction: response
  MoveParticipantFunction->>User: send Invitation
  User->>Teams: Accept Invitation
  User->>Teams: Join Hearing Room
  MoveParticipantFunction->>-GraphClient: deleteParticipant(user)
```

</details>
<!-- generated by mermaid compile action - END -->

### Courtroom API

The Coutroom API is written in TypeScript using NestJS and hosted on an Azure App Service. The API communicates with a CosmosDB
instance to store entity data. The Web API dispatches events to the Event Grid to notify the different handlers that an
action has been taken by the user (or later by external CMS systems - pending security model for calls).
Internally the Web API uses the [Mediator Pattern](https://en.wikipedia.org/wiki/Mediator_pattern), implemented by
using the [nestjs CQRS module](https://docs.nestjs.com/recipes/cqrs), to decouple business logic from the specific
implementation of the handlers. This provides flexibility in deciding how to route different types of requests.

### Notification Hub

The Azure SignalR Service provides real-time UI updates to the client. The notification hub will pull events directly
from the Event Grid and send updates to the client as necessary. Rather than deploying a new Web API instance, which may
require additional resources such as a Redis Cache, we will use the Azure SignalR service integration with Azure Functions.

### Integration Handlers

The primary application domain or Integration Handlers are a collection of Azure Functions that either listens to external
events or internal domain events from the Event Grid.

There are two primary categories of Integration handlers:

1. Call management bot
   - Receives events from the Bot Framework which includes all the external
     notifications from the Teams meetings. The purpose of this listener is to
     take the external Teams events and convert them to an internal domain
     representation of that event and then send that event to the Event Grid.
     This allows abstraction of the bot functionality into generic domain
     events.
   - Receives internal domain events and converts those into Graph API service
     calls. This is our primary integration point with the Graph SDK, and
     abstracts the Graph SDK into a single, multi-function adapter.
2. Notification Hub
   - Receives a subset of internal domain events that would need to reflect a UI
     update and using the SignalR output binding in the Azure Function sends
     those messages to the users.

### Courtroom Database

The solution uses CosmosDB to store entity information and state of attendance in the various hearing rooms. CosmosDB has
court specific JSON that can be amended to suit the court preferred terminology and Microsoft Teams layout.

### Azure Blob Storage

Use for various persisted hearing specific data including emails and future audio cues.

## Architecture Notes

The following diagram highlights a more complete picture of the interactions in this solution architecture:

![Calls](./EventDrivenMicroservices.png)

### Bot

The term bot here is a bit deceiving; many of the bot operations are handled in the Integration Handlers as the
notifications that we receive via the [Azure Bot Service](https://docs.microsoft.com/en-us/azure/bot-service) are
Graph notifications that are processed. The bot component is registered, via Terraform, to the
[Azure Bot Service](https://docs.microsoft.com/en-us/azure/bot-service). The full details of how the bot is used to
communicate with this [Azure Bot Service](https://docs.microsoft.com/en-us/azure/bot-service) and the Microsoft Graph
are documented [here](..\features\consistent-join.md#Azure-Bot-Service).

The bot is also unique in that it accepts direct "Commands" in addition to Events. This is where we expect an HTTP REST
call to return a response directly to the Courtroom API. For example, sending messages to participants in a
private party room.git u

### Monitoring & Observability

There are no customer requirements for monitoring & observability, however we use the
[WinstonJs](https://github.com/winstonjs/winston) inside our Courtroom API to log to Application Insights.
Our UI code also logs to the same Application Insights instance.
