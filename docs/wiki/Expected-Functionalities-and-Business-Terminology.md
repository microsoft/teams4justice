# Teams for Justice Expected Functionalities and Business Terminology

## Purpose of this document

The purpose of this document is to outline the desired functionalities and feature sets within the “Teams for Justice”
Microsoft Teams’ application hereinafter referred to as the “Product”.
It is also intended to outline the desired business behaviour expected from these feature sets.

This document is intended to describe the “what” and help discussions about the “how”.

The document represents the latest information from a product owner’s point of view and builds on prior history and evolution
of requirements.

## Document updates and location

It is expected that once the first version of this document is released. The document is moved to an MD file inside the main
repo. From that point forward, any update to this document will be done as a pull request.
Technical implementation
This is not a technical implementation document. Contents of this document will guide technical implementation through
outlining expected functionalities and feature sets of the product.

## User stories

Contents of the document should not be treated as user stories but used to validate existing user stories, their acceptance
criteria, and write new ones if needed to cover any gaps.

## What this document isn’t

This document is not a business requirements document although it builds on business requirements.
This document is also not a technical implementation document. It provides relevant business context that will help
guide and validate the technical implementation.

## How to use this document

Contents of this document can be used to better support:

1. **Writing, refining, and prioritising user stories:** Specifically, writing better business centric descriptions for user
   stories and elaborate acceptance criteria for each story.
2. **Creating, validating, and refining implementation approach:** Technical design and implementation fit for purpose
   and no critical desired functionalities missed.
3. **Writing and validating acceptance criteria:** Specify/Detail acceptance criteria for user stories where applicable and
   support product’s incremental development in line with the desired functionalities.
4. **Guiding priorities:** Making objective decisions about priorities and provide clear context to what business value is
   gained/lost if a particular feature set was prioritised or not. It’ll also aid better discussions with product owner.
5. **Answering product related questions:** Act as reference to answer questions about product.
6. **Testing:** Help testing efforts and support product’s increments released to deliver on user’s expectations.
7. **Helping product’s catcher:** Catcher is the entity that to own ongoing development and maintenance of the product
   once the core team have disengaged. Document will outline desired functionality for features yet to be developed.
   The catcher will benefit from keeping this document updated.
8. **Take to market:** Provide an artefact used to take this product to market as and if required.
9. **Terminology:** Establish unified and consistent terminology.
10. **Design:** Update UI design in Figma so Figma remains the source of truth for what the final UI is.

_**Note:**_ _There is no guarantee that every functionality mentioned in this document will be implemented.
Product backlog is a living document and will grow as part of product development and update._

## Terminology

**Readers of this document need to be familiar with the below terminology before reading this document.**

- **Case:** A legal case is in general is a dispute between parties which may be resolved by court or by another legal proces.
- **Hearing:** The hearing is the part of a legal proceeding where the involved parties for example present
  evidence and submissions to court.
  A case can have one or more hearings.
- **Room:** A room anywhere in this document is a Microsoft Teams online meeting created within the product
  to satisfy a business requirement.
  The term “room” is not used in any other context in this document.
- **Participant:** Refers to a person or entity joining a meeting as a Participant.
  Typically, a user that dialled in to the meeting through the joining details distributed upon creating a hearing.
- **Invitee:** Refers to the details stored in Cosmos Database about a person/entity. Mainly their email address
  and relation to the hearing.
- **Moderator:** Is a user of the “Arena View” with rights to manage
  the hearing process by joining meetings, admit participants to the hearing, create custom meetings,
  reassign participants, move back to rooms, …
- **Participants identification:** Refers to the process where invitees’ details are matched to participants details to
  determine who the participants are, which group do they belong to,
  and as such which meetings they should be routed to next.
- **Invite:** Applies to invitees by way of allocating invitees to a group upon creating a hearing. i.e., Defendant.
- **Assign:** Applies to participants by way of inviting participants to join meetings based on the invite details specified
  upon creating a hearing.
- **The Bot:** The bot anywhere in this document or in any context related to this product refers to a functionality of a
  participant in the meeting. The bot does not perform any function outside the boundaries of inviting participants to meetings,
  joining meetings related to the hearing, or sending messages in a meeting it's attending when asked by a moderator.
- **Reception:** This is the default meeting that gets created upon creating a case.
  The joining information for the reception meeting is what all invitees receive.
- **Case Room:** The term "case" room anywhere in this document refers to the Microsoft Teams online meeting created
  for a particular case and persisted throughout all hearings for that case.
- **Party rooms:** A Party room is a Microsoft Teams online meeting where one or more participants are invited to for a particular
  purpose. For example: Defendant, Party, Plaintiff (Applicant), or Custom.
- **Solo private rooms:** A solo private room is a Microsoft Teams Online meeting with the exception that
  only one participant is allowed to attend or be present in the room. If an external participant
  belongs to a group/type where segregation of participants is required.
  Then a solo private room is created for each participant.
- **Arena view:** The arena view is a name given to the user interface of the main product screen.
  It has two main sections: A **"Case Room View"** at the top and A **"Private rooms view"** at the bottom.
  Each section has links/buttons where certain commands can be initiated.

## Teams for Justice

Teams for Justice is a product that aims to provide a Microsoft Teams experience that accommodates
the general needs of Courts in the digital world and materially improves the experience of managing
and moderating online hearings.

The main product's goal is to empower court moderators to ‘bring back order to the courts.’

## Product feature sets

Teams for Justice has three main components:

- A. Creatie and Edit hearing forms.
- B. Meetings management and heartbeat.
- C. Arena View and Calendar.

## Create/Edit hearing

It is a expected that upon creating a hearing, the list of invitees and their roles in the hearing
(Witness, Defendant, Applicant, …) is generated and stored for future matching of invitee's data with participant's data.

Details of how a hearing is created/edited is out of scope of this document. The only exception to that is the requirements
to respond to editing the hearing time or cancelling the hearing which are covered in later sections in this document.

## Invitees and participants

When an invitee clicks on the reception meeting joining details or dial in to the reception meeting, they become participants.

## Participants lifecycle

## Participants joining the reception meeting

**It is expected that every participant will join the reception meeting as a first step.**

Upon creating a hearing, “Reception meeting” joining information will be sent to invitees to dial in to the reception meeting.
This is the default meeting in which participants join by email or phone as a first step in the process.

**It is expected the bot would have already joined the reception meeting and is able to detect participants joining
to initiate further actions.**

## Participants validation

It is a expected that participants joining the reception meeting are validated through matching invitee’s
information with the participant’s information.

**It is expected that the next meeting the participant is to be routed to is identified upon validation.**

When a participant joins a meeting, joining information can be validated against invitees’ data stored as a result of creating
the hearing. Validation can result in one of the following **three** scenarios:

1. **Participant is an _internal_ user:** This means that the participant is part of the tenant and not a guest.
   (I.e., An authorised court employee).
   **It is expected to route internal users directly to the case room upon joining the reception meeting and upon being
   validated as internal tenant users.**

2. **Participant is an _external_ known user:** This means that the participant is an external (non-tenant) user
   that is known to the application upon validating the joining details with the details available within the application.
   Upon validation, the user would need to belong to one of the following:

   1. **Applicant:** Participant is identified as part of the Applicant party.
   2. **Applicant Witness:** Participant is identified as an Applicant Witness.
   3. **Defendant:** Participant is identified as part of the Defendant party.
   4. **Defendant Witness:** Participant is identified as a Defendant Witness.
   5. **Others:** Participant is identified as part of another group. I.e. Translators, SMEs, ...

3. **Participant is an _unknown_ user:** This means that the participant is an external (non-tenant) user whose details
   are not known to the application.

_**Note:** Anonymous users without a recognised email address or phone number are excluded from
this validation process as the policy at the Microsoft Teams tenant level will restrict that._

## Rooms creation

Rooms are created for participants either upon creating a hearing or as participants arrive.
The number of rooms depend on the number of participants and the requirements for participants
to join party rooms or solo private rooms.

**It is expected that the bot is added to every room so the bot can invite participants to the room as and when
required.**

## Room types

Room type in this context refers to the business classification and not the technical implementation.

1. **Reception**
   The reception is a Microsoft Teams online meeting. It is the first meeting where every participant joins upon interacting
   with the product.

   - It is the meeting where the joining details are sent to invitees when a hearing is created.
   - It will host all participants while the next routing action is determined.
   - In reception, routing is done immediately based on the identification result.

   **It is expected that the reception meeting is persisted throughout all hearings in the case.**

2. **Case room**
   The case room is a Microsoft Teams online meeting where the hearing is conducted.

   **It is expected that the case room is persisted throughout all hearings in the case.**

   **It is expected that the joining details for the case room are never shared with invitees or participants.**

   **It is expected that every participant is admitted to the case room and not join the case directly.**
   This is to ensure that the joining information of the case room is protected.

3. **Party rooms:**
   Party rooms are Microsoft Teams online meetings created for a particular type of participants. Product recognises the
   following party room types:

   1. **Applicant:** A Microsoft Teams online meeting created to host (invite) all users identified as Applicant.
   2. **Defendant:** A Microsoft Teams online meeting created to host (invite) all users identified as Defendant.
   3. **Custom:** A Microsoft Teams online meeting created through the “Arena view” and used to host (invite) all users
      individually invited to join that meeting.

   **It is expected that the product can group participants based on the meeting they are attending.**

4. **Solo rooms:**
   Where a requirement exists to segregate participants in individual rooms.
   A dedicated room (meeting) is created per each participant.
   The following room types are created based on one room per participant (solo rooms):

   1. **Witness:** An individual Microsoft Teams online meeting is created for every participant identified
      as a witness while the next routing action is determined.
   2. **Lobby:** An individual Microsoft Teams online meeting is created for every unknown external user
      or a participant dialling through a phone while the appropriate routing action is determined.

## Participants routing

The below flow demonstrates the routing logic and expected functionalities.
Each functionlaity is explained in details in the below sections:
[![Routing Flow](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcblxuICAgIHN1YmdyYXBoIENhbGxNYW5hZ2VtZW50XG4gICAgICAgIEJBSVtJbnZpdGUgdG8gTWVldGluZ10gIFxuICAgICAgICBCQVNbU2VuZCBNZXNzYWdlXSAgXG4gICAgICAgIEJBUltSZW1vdmUgQm90IGZyb20gTWVldGluZ10gICBcbiAgICAgICAgQkFBW0FkZCBib3QgdG8gbWVldGluZ11cbiAgICAgICAgQkFSRVtJcyBib3QgaW4gbWVldGluZ11cbiAgICBlbmRcbiAgICBcbiAgICAgXG4gICAgc3ViZ3JhcGggQm90SW5SZWNlcHRpb25cbiAgICAgICAgTVBbTWF0Y2ggcGFydGljaXBhbnQgdG8gaW52aXRlZV0gXG4gICAgICAgIE1QIC0tPiBJVXtJbnRlcm5hbD99IFxuICAgICAgICBJVSAtLT58aW50ZXJuYWw6IGhlYXJpbmcgbWVldGluZyBib3R8IEJBSVxuICAgICAgICBJVSAtLT58ZXh0ZXJuYWx8IENFe0lkZW50aWZ5fSBcbiAgICAgICAgQ0UgLS0-fHVua25vd258IExPQkJZW0NyZWF0ZSBMb2JieSBNZWV0aW5nXSBcbiAgICAgICAgTE9CQlkgLS0-IEJMT0JCWVtBZGQgQm90IHRvIExvYmJ5IE1lZXRpbmddIFxuICAgICAgICBCTE9CQlkgLS0-IHxhZGQgYm90fEJBQSBcbiAgICAgICAgQkxPQkJZIC0tPiBsYm90SVtJbnZpdGVdIC0tPiB8bG9iYnkgbWVldGluZyBib3R8QkFJXG4gICAgICAgIENFIC0tPnx3aXRuZXNzIGZvdW5kfCBXW0NyZWF0ZSBXaXRuZXNzIE1lZXRpbmddIFxuICAgICAgICBXIC0tPiB3bWJbQWRkIEJvdCB0byBXaXRuZXNzIE1lZXRpbmddIC0tPiB8YWRkIGJvdHxCQUFcbiAgICAgICAgd21iIC0tPiB3Ym90SVtJbnZpdGVdIC0tPiB8d2l0bmVzcyBtZWV0aW5nIGJvdHxCQUkgXG4gICAgICAgIENFIC0tPnxleHRlcm5hbCBmb3VuZDogcGFydHkgbWVldGluZyBib3R8IEJBSVxuICAgIGVuZFxuICAgIFxuICAgIHN1YmdyYXBoIFRlYW1zUGFydGljaXBhbnRcbiAgICAgICAgc3R5bGUgVGVhbXNQYXJ0aWNpcGFudCBjb2xvcjp3aGl0ZSwgZmlsbDpUSElTVExFLHN0cm9rZTpNRURJVU1QVVJQTEVcbiAgICAgICAgUEooW1BhcnRpY2lwYW50IEpvaW5zXSkgIC0tPiB8UGFydGljaXBhbnQgIFVwZGF0ZXxNUFxuICAgICAgICBzdHlsZSBQSiBmaWxsOkxJR0hUR1JFRU4gXG4gICAgZW5kXG5cbiIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In0sInVwZGF0ZUVkaXRvciI6ZmFsc2UsImF1dG9TeW5jIjpmYWxzZSwidXBkYXRlRGlhZ3JhbSI6ZmFsc2V9)](https://mermaid-js.github.io/mermaid-live-editor/edit/##eyJjb2RlIjoiZ3JhcGggTFJcblxuICAgIHN1YmdyYXBoIENhbGxNYW5hZ2VtZW50XG4gICAgICAgIEJBSVtJbnZpdGUgdG8gTWVldGluZ10gIFxuICAgICAgICBCQVNbU2VuZCBNZXNzYWdlXSAgXG4gICAgICAgIEJBUltSZW1vdmUgQm90IGZyb20gTWVldGluZ10gICBcbiAgICAgICAgQkFBW0FkZCBib3QgdG8gbWVldGluZ11cbiAgICAgICAgQkFSRVtJcyBib3QgaW4gbWVldGluZ11cbiAgICBlbmRcbiAgICBcbiAgICAgXG4gICAgc3ViZ3JhcGggQm90SW5SZWNlcHRpb25cbiAgICAgICAgTVBbTWF0Y2ggcGFydGljaXBhbnQgdG8gaW52aXRlZV0gXG4gICAgICAgIE1QIC0tPiBJVXtJbnRlcm5hbD99IFxuICAgICAgICBJVSAtLT58aW50ZXJuYWw6IGhlYXJpbmcgbWVldGluZyBib3R8IEJBSVxuICAgICAgICBJVSAtLT58ZXh0ZXJuYWx8IENFe0lkZW50aWZ5fSBcbiAgICAgICAgQ0UgLS0-fHVua25vd258IExPQkJZW0NyZWF0ZSBMb2JieSBNZWV0aW5nXSBcbiAgICAgICAgTE9CQlkgLS0-IEJMT0JCWVtBZGQgQm90IHRvIExvYmJ5IE1lZXRpbmddIFxuICAgICAgICBCTE9CQlkgLS0-IHxhZGQgYm90fEJBQSBcbiAgICAgICAgQkxPQkJZIC0tPiBsYm90SVtJbnZpdGVdIC0tPiB8bG9iYnkgbWVldGluZyBib3R8QkFJXG4gICAgICAgIENFIC0tPnx3aXRuZXNzIGZvdW5kfCBXW0NyZWF0ZSBXaXRuZXNzIE1lZXRpbmddIFxuICAgICAgICBXIC0tPiB3bWJbQWRkIEJvdCB0byBXaXRuZXNzIE1lZXRpbmddIC0tPiB8YWRkIGJvdHxCQUFcbiAgICAgICAgd21iIC0tPiB3Ym90SVtJbnZpdGVdIC0tPiB8d2l0bmVzcyBtZWV0aW5nIGJvdHxCQUkgXG4gICAgICAgIENFIC0tPnxleHRlcm5hbCBmb3VuZDogcGFydHkgbWVldGluZyBib3R8IEJBSVxuICAgIGVuZFxuICAgIFxuICAgIHN1YmdyYXBoIFRlYW1zUGFydGljaXBhbnRcbiAgICAgICAgc3R5bGUgVGVhbXNQYXJ0aWNpcGFudCBjb2xvcjp3aGl0ZSwgZmlsbDpUSElTVExFLHN0cm9rZTpNRURJVU1QVVJQTEVcbiAgICAgICAgUEooW1BhcnRpY2lwYW50IEpvaW5zXSkgIC0tPiB8UGFydGljaXBhbnQgIFVwZGF0ZXxNUFxuICAgICAgICBzdHlsZSBQSiBmaWxsOkxJR0hUR1JFRU4gXG4gICAgZW5kXG5cbiIsIm1lcm1haWQiOiJ7XG4gIFwidGhlbWVcIjogXCJkZWZhdWx0XCJcbn0iLCJ1cGRhdGVFZGl0b3IiOnRydWUsImF1dG9TeW5jIjpmYWxzZSwidXBkYXRlRGlhZ3JhbSI6ZmFsc2V9)

<details>
   <summary>Mermaid markup</summary>
graph LR

    subgraph CallManagement
        BAI[Invite to Meeting]
        BAS[Send Message]
        BAR[Remove Bot from Meeting]
        BAA[Add bot to meeting]
        BARE[Is bot in meeting]
    end


    subgraph BotInReception
        MP[Match participant to invitee]
        MP --> IU{Internal?}
        IU -->|internal: hearing meeting bot| BAI
        IU -->|external| CE{Identify}
        CE -->|unknown| LOBBY[Create Lobby Meeting]
        LOBBY --> BLOBBY[Add Bot to Lobby Meeting]
        BLOBBY --> |add bot|BAA
        BLOBBY --> lbotI[Invite] --> |lobby meeting bot|BAI
        CE -->|witness found| W[Create Witness Meeting]
        W --> wmb[Add Bot to Witness Meeting] --> |add bot|BAA
        wmb --> wbotI[Invite] --> |witness meeting bot|BAI
        CE -->|external found: party meeting bot| BAI
    end

    subgraph TeamsParticipant
        style TeamsParticipant color:white, fill:THISTLE,stroke:MEDIUMPURPLE
        PJ([Participant Joins])  --> |Participant  Update|MP
        style PJ fill:LIGHTGREEN
    end

</details>

**It is expected that participants are immediately routed upon joining the reception meeting based on
the routing logic specified below.**

_Participants with a requirement to be segregated will be invited to attend the solo room
specially created for them as they join and will be invited to that meeting by the bot already attending that meeting._

_Participants with no segregation requirements will be invited to join the meeting they should be in
by the bot attending that meeting._

Routing is an automated function executed by the “bot” attending the meeting that
the participant should be routed to and is determined based on participants identification results as follows:

1. **Internal participants:** Internal users are automatically routed to the case room they should be attending.
   **It is expected to route internal users to the hearing room directly.**
2. **External known participants:**

   1. **Defendant:** Defendant participants are routed to the defendant party room.
   2. **Applicant:** Applicant participants are routed to the Applicant party room.
   3. **Witness:** Every witness is routed to a dedicated witness meeting specially created for that witness.
   4. **Other known users:** Every Participant known to the tenant such as experts and SMEs known to be
      part of another group. I.e. Translators, SMEs, ... will be routed to a dedicated lobby room.

   **It is expected that the product can differentiate between Defendant Witness and Applicant Witness
   and name the online meeting participants are routed to accordingly.**

3. **External unknown participants:** Any unknown participant will be routed to a lobby meeting
   specially created for that participant.
   This is to satisfy the requirement of segregating unknown users.
   For this context. Every unknown external participant is added to a solo room until further action is initiated.

## Rerouting participants (Reassigning)

**It is expected that the moderator can reroute (reassign) participants from the meeting they are currently attending
to another meeting they should be attending.**

The reassign will be done by the moderator from the Arena View where the moderator can specify the meeting
in which the participant needs to be rerouted to.

**It is expected that the product will update the Cosmos invitee records as part of reassigning participants.
This is so the participant can be routed to the correct meeting the next time they dial in.**

**It is expected that the product will create a new room if the participant is being rerouted
to a room that does not exixt**

## Joining the hearing

**It is expected that except for users identified as internal participants (tenant users) are routed from reception
to the hearing directly, everyone else is routed to a party room first before they’re added to the case room.**

When its time for an external participant to join the case room.
The Bot attending the case room is “asked” to invite that participant to the case room.

This “ask” is sent upon initiating an “admit to hearing” action in the Arena View by the moderator.

## Move back to Rooms

The move back to rooms action is triggered from the Arena View by the moderator.
The following action is expected to happen when move back to rooms is initiated:
Invite **"all"** participants back in the rooms they were in before they were admitted to the hearing.
There is no requirement to empty the hearing room from all external participants. This will be manually done if needed.

## The Bot (Online meetings manager)

The bot is a critical part of the product. It performs the functions of creating meetings related to
the hearing as needed and inviting participants to these meetings as and when required.
The bot can also send messages to participants when instructed by the moderator.
Below the details of the functions executed by the bot:

### Act as a meeting attendant

The bot anywhere in this document or in any context related to this product refers to another participant in the online meeting.
The bot does not perform any function outside the boundaries of inviting a participant to a meeting,
joining meetings related to a hearing, or sending a message in a meeting it's attending.
It does not refer to any AI feature or access to any database.

The bot enables communications within the meeting by inviting the right participants to the right meeting
they should be joining. It does not communicate with any participant but may send messages on behalf
of the moderator to the meeting room.

The bot **DOES NOT** in any shape or form:

- Perform any role whatsoever court proceedings or enforce compliance.
- Listen, record, or react to any conversation.
- Interact with users directly.

### Attending every meeting as the first attendee

**The bot is expected to be added to every online meeting before the start of the meeting.**
This will allow the bot to invite participants to the meetings the bot is attending.

### Attend multiple meetings at the same time

The bot is expected to attend all active meetings related to the hearing at the same time.
This will allow the bot to manage attendees and add/move participants as needed.

### Send messages on behalf of the moderator

The bot is expected to be able to send a message on behalf of the moderator.
The bot will not construct nor understand the message. It will only send (pass) the message
the moderator asks the bot to send.

The send message function is only required in party rooms. It is not required in solo rooms.

### Add participants to meetings (Invite to meeting)

**It is expected that the bot can invite people to the meetings they should be attending.
The bot attending the meeting that the participant should be attending will invite the participant.**

_Example: If the participant is to be routed from the witness room to the hearing room. The bot in the hearing room
will invite the participant to attend and the participant will receive a call to accept and as such join the case room._

### Manage the meetings health (heartbeat)

The bot will execute functions needed to keep meetings running and healthy. It’ll also execute clean-up functions as follows:

### Timer

**The bot is expected to check meetings starting times and ending times to add and remove the bot from the meeting.
Expected times to be checked:**

- 24 hours after meeting end. This is used to initiate an action to remove the Bot from the meeting.
  This applies to all meetings.
- 1 week prior to the meeting. This is used to add the bot to the meeting. This applies to all meetings.

The above two times apply to creating a new hearing and editing an existing hearing.

_For example: Editing a hearing might mean that the hearing is no longer starting in a week and as such the bot
will need to be removed then readded one week close to the hearing time._

### Add bot to meeting

The bot is expected to be added to the meeting as the first participant.

### Keep bot in meeting

The bot is expected to check if bot is still in meeting. If not, then the bot is expected to be re-added to the meeting.

### Remove bot from meeting

The bot is expected to be removed from the meetings in these scenarios:

1. Meeting is cancelled.
2. Meeting time has changed and is no longer happening within one week.

### Remove participant from meeting

**The bot is expected to be able to remove a participant from a meeting.
This is needed in situations where the bot is expected to empty the reception room from
any participant that hasn’t been routed.**

### Respond to cancelling a hearing

**The bot is expected to Remove the bot from meetings if the hearing is cancelled.**

### Respond to editing a hearing

**The bot is expected to remove the bot from meetings if these meetings are no longer happening within a week.**

**The bot is also expected to remove participants from meetings that ended in the last 24 hours.**

### Arena view

The arena view is a user interface or admin view of the application available for the moderator
in order to join the hearing and/or execute commands needed to manage the hearing.
It is divided in two parts as follows:

**One: Upper part: Case Room View**
The Case Room View is displayed as the upper part of the arena view. It performs the below functionalities:

**A. Display information about the Case Room. These are:**

1. Date and time
2. Case name
3. A label indicating it’s an official hearing
4. Judge/s Name/s
5. Judge location (In room or not in room)
6. Participants list attending (Meeting attendees)

**B. Initiate commands “asks” related to that hearing. These are:**

1. Creation of a custom room
2. Joining the case room (for the Moderator)
3. Add an internal participant to the case room
4. Send a message to the case meeting using meeting chat
5. Copy reception meeting joining details/URL
6. Move external participants back to rooms

**Two: Lower part: Rooms View (Participants Groups)**
Participants lists grouped by the meetings they are currently attending will be displayed in
the lower part of the arena view. The rooms section of the arena view performs the following functionalities:

**A. Display participants grouped by the meetings they are currently attending.**

These are:

**Group name:**
This is the name of the group in which all participants belong to.
Or the meeting type (Room Type) in which they are attending.

_For example, to display witnesses, the group name will be called witnesses and
will display the list of all witnesses in attendance.
These witnesses are however kept in solo rooms but for the purposes of the user interface,
the list of witnesses will show as one block showing all witnesses in attendance._

The following group names are recognised by the product in the Arena View:

1. **Lobby:** Will show a list of all participants attending individually created lobby meetings.
2. **Applicants:** Will show a list of all participants currently attending the Applicant meeting.
3. **Defendants:** Will show a list of all participants currently attending the defendant meeting.
4. **Witnesses:** Will show a list of all participants currently attending individually created witness meetings.
5. **Custom:** Will show a list of all participants currently attending the custom meeting.
   The name of the meeting will be shown as specified in the custom room creation.
6. **Lobby:** Will show a list of all participants currently attending the individually created lobby meetings.

**B. Initiate commands within each group that either apply to a single participant or the entire group.**

These are:

1. **Admit to hearing:** For a single participant
   This will initiate a command “Ask” to invite the participant to the case room.
2. **Admit All to hearing:** For the entire group
   This will initiate a series of commands “asks” to invite each participant in this group to the hearing
3. **Join the meeting – Party room:** This action allows the moderator to join the meeting.
   This applies to the meeting where all participants are attending the same meeting (no segregation).
   Groups where the join meeting command can be initiated: Applicant, Defendant, Custom
4. **Join the meeting – Solo room:** This action allows the moderator to join the meeting.
   This command applies to one participant kept in a separate meeting and is initiated once for every participant.
5. **Send a message – Party room:** This will send a message to the meeting selected by the moderator.
6. **Reassign Participant (Move to another room):** This will enable the moderator to move a participant to another
   room selected from a list of rooms
   created for this case.
7. **Change display name - Participant:** This will enable the moderator to change the display name of a participant.
8. **Rename a group:** This will allow the moderator to change the display name of a party room or a custome room.
