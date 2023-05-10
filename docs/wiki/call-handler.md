# Teams Online Meeting Calls Handler

|               |              |
| ------------: | ------------ |
|     _Author:_ | Danny Garber |
| _User Story:_ | <USER_STORY> |
|       _Date:_ | Apr 2021     |

- [Teams Online Meeting Calls Handler](#teams-online-meeting-calls-handler)
  - [Overview](#overview)
  - [Types of Handlers](#types-of-handlers)
  - [Data Model](#data-model)
  - [Initializing](#initializing)
  - [Usage](#usage)
  - [Call Handler Lifetime](#call-handler-lifetime)
  - [Conclusion](#conclusion)
  - [Additional Resources](#additional-resources)

## Overview

When Bot joins the scheduled meeting (e.g. Hearing Room), the Teams generates a
unique Call Id, by which then Bot can later identify the meeting details, such
as meeting participants, when the meeting events are captured via Teams
notifications triggered and sent by MS Graph Online Communications. Due to the
nature of this solution, there could be tens or even hundreds of simultaneously
running Teams Online meetings for which Bot is going to receive event
notifications. In order to manage and handle each meeting individually, the
meeting Call handlers are required.

## Types of Handlers

There are two types of call handlers currently present in the baseline Virtual Court solution:

- Session Call Handler - is the memory bound dictionary that keeps the list of
  CallHandler objects with the call Id key. This handlers are useful when the
  entire Bot and Call objects are required at any processing moment. This is an
  example of the session handler definition in C#:

  ```c#
  public ConcurrentDictionary<string, CallHandler> CallHandlers { get; } = new ConcurrentDictionary<string, CallHandler>();
  ```

- Persistent Call Handler - is the JSON record persisted in the Cosmos DB that
  maps the Call to the Hearing in which this call is being processed.

  This handler has its advantage over the Session Handler as it is getting
  stored in the persistent storage and can be retrieved upon the need, for
  example: when the Bot is rejoining the meeting. Another big advantage of using
  Persistent Call Handler is a straight forward mapping between the Teams Call
  (`CallId`) and the Hearing Entity (`HearingId`).

  As such, the remaining of this document is entirely dedicated to the
  Persistent Call Handlers as the best practice guidance of managing Teams calls
  in the solution.

## Data Model

Teams Call Handlers must contain just enough information to allow developers to
map the Call Object (received from the Teams Notifications) to the Hearing
Entity for which this call is being processed. Additionally, in the multi-tenant
scenarios, it's advisable to store the Tenant Id in which this Call is being
processed. Room Type can also be handy, as there are cases when the data flow
fork is determined by the virtual room type in which the given call is happening.

Below is an example of the Persistance Call Handler (or Call Mapper) JSON object that is stored to Cosmos DB:

```c#
      /// <summary>
      /// Gets or Sets Call Id.
      /// </summary>
      [Required]
      [DataMember(Name = "id")]
      public string Id { get; set; }

      /// <summary>
      /// Gets or Sets Hearing Id.
      /// </summary>
      [Required]
      [DataMember(Name = "hearingId")]
      public string HearingId { get; set; }

      /// <summary>
      /// Gets or Sets Tenant Id (for multi-tenant scenarios)
      /// </summary>
      [Required]
      [DataMember(Name = "tenantId")]
      public string TenantId { get; set; }

      /// <summary>
      /// Gets or sets a value of the room type
      /// </summary>
      [Required]
      [DataMember(Name = "roomType")]
      public RoomType RoomType { get; set; }

```

## Initializing

The Persistence Call Handler record is initialized and stored in the database
with each new meeting that the Bot joins. This could be done via DI (dependency injection) processor
that is called by the Bot when it joins the meeting. An excrept code of such
call is shown below:

```c#
        public async Task<ICall> JoinTeamsCallAsync(TeamsCallRequestData callRequestData)
        {
            // Join the call
            var botMeetingCall = await this.JoinCallAsync(callRequestData).ConfigureAwait(false);

            // Create a session call handler
            this.AddTeamsCallToHandlers(
                callRequestData.ScenarioId,
                botMeetingCall,
                new TeamsCallContext(callRequestData.CallType, botMeetingCall.Id, callRequestData.MeetingRoomType));

            // Create a persistent Call Handler
            await this.callProcessor.SaveCallAsync(
              botMeetingCall,
              callRequestData.ScenarioId,
              callRequestData.MeetingRoomType);

            return botMeetingCall;
        }

```

## Usage

Call handlers are used to determine the meeting and other details (e.g. Hearing,
Room type, participants) when the meeting event notification is received by a
Teams In Meeting handler. For example, when a user joins the General Room, it
must be moved to the designated room upon user identification. In such scenario,
the Call Handler is used to find the Hearing details for which this new meeting
participating is calling in.

Here's the excerpt of the code that does that:

```c#
        protected override async void ParticipantsOnUpdated(IParticipantCollection sender, CollectionEventArgs<IParticipant> args)
        {
            try
            {
                foreach (var participant in args.AddedResources)
                {
                    // for now we want the bot to only subscribe to "real" participants
                    var participantDetails = participant.Resource.Info.Identity.User;

                    if (participantDetails != null)
                    {
                        // subscribe to the participant updates, this will indicate if the user started to share,
                        // or added another modality
                        participant.OnUpdated += this.ParticipantOnUpdated;

                        // Check if this call was previously registered in the Call/Hearing map
                        var callProcessor = new CallProcessor();

                        var hearing = await callProcessor.
                                GetHearingAsync(
                                  this.Call.Id,
                                  new HearingProcessor());

                        if (hearing != null
                        && this.roomType == RoomType.General)
                        {
                            // Move participant into a designated room
                            await this.MoveParticipantAsync(
                              hearing, participantDetails);
                        }
                    }
                }

                ...
                [the rest of the code is taken out for brevity]
            }
            catch (Exception e)
            {
                this.GraphLogger.Verbose(e.Message);
            }
        }

```

## Call Handler Lifetime

Persistance Call Handlers have the same lifetime as the meetings they are
associated with. Therefore, when the meeting is ended, the appropriate measures
must be taken to assure that the corresponding Call Handler is removed from the
database. This can be achieved in the Teams meeting event when the meeting is
terminated.

```c#
        protected override void CallOnUpdated(ICall sender, ResourceEventArgs<Call> args)
        {
            ...
            [The rest of the code is kept out for brevity]

            if (sender.Resource.State == CallState.Terminated)
            {
                // Remove Call Handler
                var callProcessor = new CallProcessor();
                callProcessor.RemoveCallAsync(sender.Id).ConfigureAwait(false);
            }
        }

```

## Conclusion

The Persistence Call Handlers are important components of the Teams call
management. They provide the bridge to the business data entities, such as
Hearing Entity, when the Teams triggers online meeting events. They can also
help in restoring the teams meeting processing of the events in the scenario
where Bot is joining the meeting "late" (e.g. due to the previous crash). While
Persistence Call Handlers do not contain huge amount of information about the
call like, for example, the Memory Dictionary Call Handlers, they are essential
for the health of the Team Meeting event processing.

## Additional Resources

For more detailed implementation of the Persistence Call Handlers, contact
[**Danny Garber**](mailto:dannyg@microsoft.com) to get access to a private repo with the
sample project implementation
