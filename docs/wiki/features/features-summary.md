# Feature Summary

For each of the key epics built for Teams for Justice, the following list contains all related user related features.

**Note**: To complete these features there are underlying services and logic that are not captured at this level.

## Current Features

| Epic                                    | User        | Feature                                                     | Description/Comments                                                            |
| --------------------------------------- | ----------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Setup                                   | IT          | Create Teams for Justice app                                | [Teams environment](..\setting-up-a-new-environment.md) and Court specific JSON |
| Scheduling                              | Moderator   | View court room schedule                                    | Uses [Custom calendering](..\ui\render-calendar-component.md)                   |
| Scheduling                              | Moderator   | [Create new hearing](.\create-new-hearing.md)               | [Various requirements](#create-and-edit-hearing)                                |
| Scheduling                              | Moderator   | View existing created hearing                               |                                                                                 |
| Scheduling                              | Moderator   | [Edit existing hearing details](.\edit-hearing.md)          | [Various requirements](#create-and-edit-hearing)                                |
| Scheduling                              | Moderator   | [Cancel existing hearing](.\cancel-hearing.md)              | Removes scheduled for hearing and all resources                                 |
| [Private Rooms](.\private-rooms.md)     | Moderator   | View all rooms related to a hearing                         | Ordered layout: Lobby, Party rooms, other solo room groups                      |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - [send message](.\send-message.md)                    | Send message each participant of a room type                                    |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - rename participant                                   | Change display name of external participant                                     |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - reassign participant                                 | Reassign and move solo external participant (to party or solo room)             |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - join                                                 | Join a single solo online meeting                                               |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - rename room                                          | Rename the solo group name                                                      |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - [admit](.\invite-to-meeting-api.md)                  | Admit individual in solo group to the hearing                                   |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Solo - [admit](.\invite-to-meeting-api.md) all              | Admit all in the solo group to the hearing                                      |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - [send message](.\send-message.md)                   | Send message to external participants in room                                   |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - rename participant                                  | Change display name of external participant                                     |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - reassign participant                                | Reassign and move party external participant (to party or solo room)            |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - join                                                | Join the party online meeting                                                   |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - rename room                                         | Rename the party room name                                                      |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - [admit](.\invite-to-meeting-api.md)                 | Admit a single external participant in the party room to the hearing            |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Party - [admit](.\invite-to-meeting-api.md) all             | Admit all external participants in the party room to the hearing                |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - create new room                                   | Create anew custom party room                                                   |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - view all                                          | View all participants in hearing                                                |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - copy link                                         | Links to reception                                                              |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - [move back to room](.\invite-to-meeting-api.md)   | Move back a single external participant from the hearing to assigned room       |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - [move back to rooms](.\invite-to-meeting-api.md)  | Move back all external participants from the hearing to their assigned rooms    |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - [send message](.\send-message.md)                 | Send message to external participants in hearing                                |
| [Private Rooms](.\private-rooms.md)     | Moderator   | Hearing - join                                              |                                                                                 |
| [Hearing Control](.\hearing-control.md) | Moderator   | Sidebar application view                                    |                                                                                 |
| [Hearing Control](.\hearing-control.md) | Moderator   | Control participant audio - mute all                        |                                                                                 |
| [Hearing Control](.\hearing-control.md) | Moderator   | Control participant audio - mute one                        |                                                                                 |
| [Hearing Control](.\hearing-control.md) | Moderator   | Message external participants                               |                                                                                 |
| [Consistent Join](.\consistent-join.md) | Participant | Automatic routing of external participants to private rooms |                                                                                 |
| [Consistent Join](.\consistent-join.md) | Participant | Automatic routing for court staff to hearing room           |                                                                                 |
| [Search](.\search-hearing.md)           | Moderator   | Search hearings by case name                                | Grouped by court room, case number, case name, timezone                         |
| [Search](.\search-hearing.md)           | Moderaror   | Search hearings by case number                              | Grouped by court room, case number, case name, timezone                         |

### Create and Edit hearing

[Create](.\create-new-hearing.md) and [Edit](.\edit-hearing.md) features encompass multiple sub-features including:

- setting the terminology set for hearing
- input [validation](..\validation.md)
- a [date time picker](..\ui\date-and-time-in-the-ui.md) control
- automatic creation of private rooms and related online meetings for the hearing
- a rich text editing control
- [send court-templated notices](.\email-notification.md)

## Future Features

Some of the key features planned for future releases:

| Epic                                    | User        | Feature                                                          | Comments             |
| --------------------------------------- | ----------- | ---------------------------------------------------------------- | -------------------- |
| [Hearing Control](.\hearing-control.md) | Moderator   | Recess - move single party to private room                       | API to be built      |
| [Hearing Control](.\hearing-control.md) | Moderator   | Recess - Notifying and transferring participants back to hearing | API exists           |
| [Hearing Control](.\hearing-control.md) | Moderator   | Reassign participant to different party                          | In private rooms     |
| [Hearing Control](.\hearing-control.md) | Moderator   | Update participant’s display name                                | In private rooms     |
| [Hearing Control](.\hearing-control.md) | Moderator   | Message party participants                                       | API exists           |
| [Hearing Control](.\hearing-control.md) | Moderator   | Message single participants                                      | API exists           |
| [Consistent Join](.\consistent-join.md) | Participant | External participant welcome audio cue                           | Code sample provided |
| [Consistent Join](.\consistent-join.md) | Participant | External participant room join audio cue                         | Code sample provided |

## Further reading

- [Functionality and terminology](..\Expected-Functionalities-and-Business-Terminology.md)
