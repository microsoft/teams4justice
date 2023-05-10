# Call Management Bot

## Overview Operations

The Call Management Bot creates and managers the following resources:

### Online Meetings

Online meetings are created for both `Hearing Room` and `Case Room`

- Hearing Room

  - Not used in Events for calendars (see below)
  - Meeting details are not sent to end users
  - On success raises `HearingRoomOnlineMeetingCreated` to Event-grid

- Case Room

  - Represents the overall `Case`
  - Used in the join info for the calendar Events sent to end users.
  - On success raises `CaseRoomOnlineMeetingCreated` to Event-grid
  - The On-line meeting details are used in the related `Hearing` calendar
    Events

| MS Graph                       | Permission                     |
| :----------------------------- | :----------------------------- |
| /users/{userId}/onlineMeetings | `OnlineMeetings.ReadWrite.All` |

### Calendar Events

Calender events are created for `Hearing`

- Hearing

  - Start and end-time is based on the `Hearing`
  - Event organizer is a system account set on the `Organisation`
  - Attendees are ?
  - On success raises `HearingCalendarEventCreated` to event-grid
  - The _onlinemeetingid_ points back to the parent `Case` _onlinemeetingid_

| MS Graph                    | Permission            |
| :-------------------------- | :-------------------- |
| /users/{id}/calendar/events | `Calendars.ReadWrite` |

## Getting started

The project is written in TypeScript/Node. Install any dependencies and set up
your development environment. Then build, run, and test the project.

## Permissions

Authorization is controlled using Azure AD Application Registration. The
required permissions are outlined in the [Application Security
Doc](../../docs/wiki/application-security.md#call-management-bot)

## Developer Access to MS Graph Endpoints

Options for developers to get familiar with MS graph.

**Option 1**: Graph Explorer

Url : <https://developer.microsoft.com/en-us/graph/graph-explorer>

Graph-explorer relies on user authentication, therefore MS Graph requests will
be limited to the permissions of the logged in user.

To request additional permission graph-explorer provides a _Modify Permission_
tab.

Additional permissions may require Admin consent.

Within the T4J Developer tenant a privileged _service account_ is available.

> Note: to ensure the required Mailbox and Calendar objects are available the
> user account must have an Exchange On-line License.

**Option 2**: Authorize MS Graph calls with an Access Token

1. Register a new App in Azure AD
1. Set required permissions
1. Request an access token from Azure AD for the App
1. Include access token in the authorization header in MS Graph request

### Obtaining authorization token

To request an Access Token for a Registered App from Azure AD:

```bash
POST
https://login.microsoftonline.com/{{TENANT_ID}}/oauth2/v2.0/token
```

Setting the request body to include the following:

```bash
client_id : {{APP_ID}}
client_secret: {{APP_SECRET}}
scope: https://graph.microsoft.com/.default
grant_type: client_credentials
```

access token request example in Postman:

![Postman request access token](oauth-request-access-token.png 'Request access
token')

Use the returned `access_token` in the authorization header of requests to MS
Graph

```bash

Authorization : bearer {{ACCESS_TOKEN}}
```

Note: A Postman Graph collection is available. See
<https://docs.microsoft.com/en-us/graph/use-postman>

## Set policy between service account and app registration

The [application needs
permissions](https://docs.microsoft.com/en-us/graph/cloud-communication-online-meeting-application-access-policy)
to run these operations on behalf of the service account user. The following
steps need to be run to enable that:

```powershell
New-CsApplicationAccessPolicy -Identity Graph-Policy -AppIds <Service Account Object ID>, <App Registration Client ID> -Description "Policy to allow online meeting access"
Grant-CsApplicationAccessPolicy -PolicyName Graph-Policy -Identity <Service Account Object ID>
```

### Setup

Some prerequisites to run this project:

- [Node](https://nodejs.org/en/download/)
- [TypeScript](https://www.typescriptlang.org/download)
- [Yarn](https://classic.yarnpkg.com/en/docs/install)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [REST Client VS Code
  extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)

Set up the local development environment:

1. Open the repository in Visual Studio Code.
1. Copy `local.settings.template.json` into a new file that is named
   `local.settings.json`.

| Variable                                                           | Description                                                                                                                                                                                                                                           |
| ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AZURE_AD_TENANT_ID                                                 | The Azure AD Tenant ID that the bot application is registered with.                                                                                                                                                                                   |
| AZURE_AD_BOT_CLIENT_ID                                             | The client ID of the application registered in Azure AD representing the bot.                                                                                                                                                                         |
| AZURE_AD_BOT_CLIENT_SECRET                                         | A secret created for the application registered in Azure AD representing the bot.                                                                                                                                                                     |
| AZURE_AD_BOT_SERVICE_ACCOUNT_OBJECT_ID                             | The object ID of the service account under which online meetings are created in Graph.                                                                                                                                                                |
| AZURE_AD_BOT_SERVICE_ACCOUNT_UPN                                   | The UPN (email) of the service account that the bot retrieves data for and acts as when performing delegated actions against Graph.                                                                                                                   |
| AZURE_AD_BOT_SERVICE_ACCOUNT_PASSWORD                              | The password for the service account that the bot retrieves data for and acts as when performing delegated actions against Graph.                                                                                                                     |
| ONLINE_MEETING_LIFECYCLE_MANAGEMENT_JOIN_BEFORE_START_DATE_MINUTES | The number of minutes the bot should join online meetings before they are scheduled to start.                                                                                                                                                         |
| ONLINE_MEETING_LIFECYCLE_MANAGEMENT_LEAVE_AFTER_END_DATE_MINUTES   | The number of minutes the bot should remain in online meetings after they are scheduled to end.                                                                                                                                                       |
| NOTIFICATIONS_AUTH_ISSUER                                          | The issuer URI that should be expected in the JWT that accompanies calls notifications.                                                                                                                                                               |
| NOTIFICATIONS_AUTH_JWKS_URL                                        | The URL that points to the JWKS endpoint containing the signing keys for the JWT that accompanies calls notifications.                                                                                                                                |
| NOTIFICATIONS_AUTH_JWKS_CACHE_MINUTES                              | The number of minutes to cache the JWKS signing keys. Once the cached keys are stale, they will be re-downloaded from the JWKS endpoint.                                                                                                              |
| NOTIFICATIONS_AUTH_DISABLED                                        | Allows for disabling calls notification authentication checks for _local development only_.                                                                                                                                                           |
| HEARING_ORGANISER_EMAIL_ADDRESS_OVERRIDE                           | is the setting which will override the Hearing Organiser "from" address when emails are sent to hearing attendees. Enter an email address if you wish to override, or leave it blank if you do not wish to override.                                  |
| HEARING_ATTENDEE_EMAIL_ADDRESS_OVERRIDE                            | is the setting which will override the Hearing Attendee "to" addresses when emails are sent to hearing attendees. Enter a list of email addresses separated by a semicolon if you wish to override, or leave it blank if you do not wish to override. |

### Build

Follow instructions in the [main README](../../README.md#Building) to build the
project.

### Run

To run and [debug the project in Visual Studio
Code](https://code.visualstudio.com/Docs/editor/debugging):

1. Open Visual Studio Code in workspace view. To do this from your terminal, run
   `code workspace.code-workspace` from the root of the repository.
1. Open the Visual Studio Code pane called **Run and Debug**.
1. To run only this project, select the launch configuration called **Debug Call
   Management Bot**. Or, to run all 5 Functions projects in parallel, choose
   **Attach to all Functions apps**.
1. Press **F5** to run the selected launch configuration.

Or, to run the project from the command line:

1. Open your terminal to the `src/` folder of the repository.
1. Run `yarn workspace call-management-bot run start` to start the project.

### Test

Now that the project is running, send test requests using the [REST Client VS
Code
extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client):

1. Open the .rest file associated with the adapter function you want to test in
   Visual Studio Code.
2. Deploy to Azure and then open [Azure Event Grid
   Viewer](https://docs.microsoft.com/en-us/samples/azure-samples/azure-event-grid-viewer/azure-event-grid-viewer/)
   in a browser to monitor for the events
3. Click the link that says **Send Request** for your request.
4. Verify the request returns a `200 OK` response.
5. View the output appear in **Azure Event Grid Viewer**

## Mapping API entities and Teams components

| Entity                     | Teams                                                                                                |
| :------------------------- | :--------------------------------------------------------------------------------------------------- |
| `Court`                    | Team                                                                                                 |
| `Courtroom`                | Team Channel                                                                                         |
| `Case`                     | Event (organizer is case moderator)                                                                  |
| `Hearing`                  | Holds the time and location information for the hearing and used for the hearing-room event duration |
| `Hearing Room`             | Event (organizer is the hearing moderator)                                                           |
| `Hearing Message`          | Chat Message                                                                                         |
| `Hearing Participant`      | Attendee/Participant/Organizer invited to the hearing                                                |
| `Hearing Room Participant` | Representation of the party actually in the room                                                     |
