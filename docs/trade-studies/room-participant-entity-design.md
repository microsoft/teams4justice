# Trade Study: Room Participant

|                 |                                                                                                                               |
| --------------: | ----------------------------------------------------------------------------------------------------------------------------- |
| _Conducted by:_ | Azadeh Khojandi, David McGhee                                                                                                 |
|  _Sprint Name:_ | 17                                                                                                                            |
|         _Date:_ | 13/08/2021                                                                                                                    |
|     _Decision:_ | Team are happy with below changes, there might be upcoming changes when `call management bot` for solo room fully implemented |

## Overview

In the system, we have two types of rooms:

- Solo rooms
- Party rooms

**Party rooms** are Teams meeting rooms that can host multiple participants.
**Solo rooms** are Teams meetings with only one participant.

As agreed on
[hearing-participants-source-of-truth.md](./hearing-participants-source-of-truth.md),
`call management bot` maps the room participant to known or unknown user and
sends an event. `API` will receive these events and persists the received data
in the datastore (CosmosDB).

## Goals

updating `hearingRoomParticipant` schema should able to support saving event
data raised by
[CaseRoomOnlineMeetingParticipantJoined](../wiki/events/CaseRoomOnlineMeetingParticipantJoined.md),
[CaseRoomOnlineMeetingParticipantLeft](../wiki/events/CaseRoomOnlineMeetingParticipantLeft.md),
[HearingRoomOnlineMeetingParticipantJoined](../wiki/events/HearingRoomOnlineMeetingParticipantJoined.md),
[HearingRoomOnlineMeetingParticipantLeft](../wiki/events/HearingRoomOnlineMeetingParticipantLeft.md),
`HearingParticipantSoloRoomCreated`
events.

It also need to follow
[solo-room-entity-design.md](./solo-room-entity-design.md) , and
[participant-photo-technical-design.md](./participant-photo-technical-design.md)
and capturing `OnlineMeetingParticipantIdentity` fields.

## Current hearingRoomParticipant enity schema

```typescript
export interface EntityBase {
  id: string;
  type: string;
  schema: string;
  editMetadata: EditMetadata;
  partitionKey: string;
}
export default class HearingParticipant implements EntityBase {
  static entityType = "hearingParticipant";
  static entitySchema = "urn:hearingParticipant/v1";
  id!: string;
  readonly type = HearingParticipant.entityType;
  readonly schema = HearingParticipant.entitySchema;
  readonly partitionKey = "id";
  organisationId!: string;
  courtId!: string;
  caseId!: string;
  hearingId!: string;
  firstName?: string;
  lastName?: string;
  displayName?: string;
  email!: string;
  phoneNumber?: string;
  participantParty!: string;
  status!: string;
  editMetadata!: EditMetadata;
}
```

## Open Question/Ask

1- what's the interface of data raised by HearingParticipantSoloRoomCreated
event?

We need solo room Id, solo room meeting details as well as participant identity.

```typescript
export interface OnlineMeeting {
   joinWebUrl!: string;
   joinInformation?: string;
}
export interface OnlineMeetingParticipantIdentity {
  id: string;
  tenantId: string;
  displayName: string;
  identityProvider: string;
}
export interface HearingParticipantSoloRoomCreated extends EventBase {
participantIdentity: OnlineMeetingParticipantIdentity;
onlineMeeting:OnlineMeeting;
caseId: string;
hearingId: string;
soloRoomId:string
participantParty: string;
}

```

2- How does the `call management bot` return back user details joined by phone?
Are we planning to use `OnlineMeetingParticipantIdentity` interface?

- **PSTN** - the public switched telephone network (PSTN) required to be
  acquired and setup in order to receive and make phone calls from Microsoft
  Teams

```json
{
  "id": "xxx",
  "tenantId": "",
  "displayName": "particpant's phone number",
  "identityProvider": "PSTN"
}
```

3- How to track court staff & Judges in the room?

## Proposed changes

1- Rename `hearingRoomParticipant` to `RoomParticipant`.

2- Rename `HearingParticipantSoloRoomCreated` to `SoloRoomOnlineMeetingCreated`

3- Update `RoomParticipant` Schema to

```typescript
export interface EntityBase {
  id: string;
  type: string;
  schema: string;
  editMetadata: EditMetadata;
  partitionKey: string;
}

export default class RoomParticipant implements EntityBase {
  id!: string;
  readonly type = RoomParticipant.entityType;
  readonly schema = RoomParticipant.entitySchema;
  readonly partitionKey = "id";
  organisationId!: string;
  courtId!: string;
  caseId: string;
  hearingId: string;
  participantIdentity!: OnlineMeetingParticipantIdentity;
  currentRoomId!: string; //The Room the participant currently is on - Solo (lobby, witness) or Party (defendant, plaintiff) room  - null for case room
  assignedRoomId: string; //The Room which participant is assigned to - Solo or party room
  participantParty: string;
  roomOnlineMeetingId: string;
  displayName?: string;
  status!: string;
  editMetadata!: EditMetadata;
  static entityType = "roomParticipant";
}
```

## Notes

1. `currentRoomId` is null when particpant is in `Case Hearing Room`

2. `currentRoomId` presents which room is particpant is currently is on - Solo
   (lobby, witness) or Party (defendant, plaintiff) room

3. `participantParty` or `assignedRoomId` will be used for moving particpants
   from `Case Hearing Room` to their original room.

4. Moderator can rename `displayName` of particpant. As a result when we recieve
   `CaseRoomOnlineMeetingParticipantLeft` or
   `HearingRoomOnlineMeetingParticipantLeft` we don't delete the
   `RoomParticipant`. The values of `currentRoomId`,`participantParty` and
   `assignedRoomId` will be null.

## Readability name change suggestions

1. Rename `hearingParticipant` to `invitees`
2. Rename `hearingRoom` to `partyRoom`
3. Rename `hearingRoomId` to `partyRoomId`
