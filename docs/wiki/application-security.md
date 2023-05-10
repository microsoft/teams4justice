# Application Security <!-- omit in toc -->

- [Overview](#overview)
- [Teams Applications](#teams-applications)
  - [Teams Application Manifest](#teams-application-manifest)
- [Teams Client App Definitions](#teams-client-app-definitions)
- [Backend Service Applications](#backend-service-applications)
  - [Courtroom Management API](#courtroom-management-api)
    - [Access Token Exchange](#access-token-exchange)
    - [Authentication](#authentication)
    - [Authorization](#authorization)
    - [Courtroom Management API App Registration Settings](#courtroom-management-api-app-registration-settings)
  - [T4J App Instance](#t4j-app-instance)
    - [T4J Application Instance App Registration Settings](#t4j-application-instance-app-registration-settings)
  - [Call Management Bot](#call-management-bot)
    - [Delegated Authentication of the Service Account](#delegated-authentication-of-the-service-account)
    - [Configuring the Service Account Settings in Teams](#configuring-the-service-account-settings-in-teams)
    - [Call Management Bot App Registration Settings](#call-management-bot-app-registration-settings)

## Overview

The system is secured through the use of Azure Active Directory (AAD). Some portions of the system use AAD Application
Identities to communicate with other services such as Microsoft Graph while others expect access tokens from AAD to be
passed to authenticate and authorize incoming callers. A high level description of each particular application in the
system can be found below along with their respective AAD configuration details.

## Teams Applications

Teams provides a native security model which applications can utilize to perform Single Sign On (SSO). It consists of
setting up a dedicated AAD Application Instance according to some specific rules and configuring that the Teams
Application to utilize that Application Instance via a manifest file that is shipped along with the application. Teams
can then exchange it's access token for an ID token which the application can then use to identify the user within the
AAD and exchange with a backend that trusts that Application for an access token to access other resources. In this
application's case we exchange the ID token for two access tokens:

- **API Access Token** - allows the Teams Applications to call the Courtroom Management REST API
- **Graph Access Token** - allows the Teams Applications to call Graph directly to retrieve information (e.g. to
  retrieve profile pictures)

### Teams Application Manifest

The entry in the Teams Application Manifest file that controls the security is `webApplicationInfo` and should look like
the following example:

```JSON
  "webApplicationInfo": {
    "id": "<Teams Application AAD Application Client ID>",
    "resource": "api://<domain of deployed teams app>/teams-app"
  }
```

- The `id` property value should be the Client ID of the AAD Application Instance; this is a guid value.
- The `resource` property represents the Application ID URI of the AAD Application Instance; this should look something
  like: `api://127.0.0.1/teams-app` for an IP based address or `api://my-virtual-court-teams-app.azurewebsites.net` for
  a DNS based address.

## Teams Client App Definitions

In order for Teams to retrieve the ID Token for the Application Instance it must be authorized as a client application
of the custom AAD Application Instance. This is done by adding two well-known Client IDs for Teams itself to the list of
Authorized client applications on the "Expose an API" blade. The two Client IDs are:

- `1fec8e78-bce4-4aaf-ab1b-5451cc387264` - The Teams mobile or desktop client application
- `5e3ce6c0-2b1f-4285-8d4b-75ee78787346` - The Teams web client application

[More details on this process are covered here in the SSO documentation for
Teams](https://docs.microsoft.com/en-us/microsoftteams/platform/tabs/how-to/authentication/auth-aad-sso).

## Backend Service Applications

Each backend application needs its own AAD Application Instance to be able to interact with other resources in the
system. Some applications need to act as a client to Microsoft Graph while others are themselves secured APIs.

### Courtroom Management API

The API is secured by AAD and requires that the client procures an Access Token to be able to call it. [In the case of
the Teams Applications this is done via Teams SSO](#authorizing-teams-to-obtain-tokens-via-sso) where the Teams
Applications exchanges the user's ID Token, which is retrieved and provided by Teams, for the API's Access Token as well
as a Microsoft Graph Access Token.

#### Access Token Exchange

The API offers a dedicated token exchange endpoint where the user's ID token can be exchanged for two different access
tokens:

1. **API Access Token** - This token enables access to the Courtroom Management API itself.
2. **Microsoft Graph Access** Token - This token enables direct access to the Microsoft Graph. At the time of this
   writing this is only used to retrieve user profile images in the Teams Applications.

#### Authentication

The bulk of the APIs require authentication. This is achieved by passing the JWT Access Tokens using the Bearer
Authorization scheme:

```plain
Authorization: Bearer <JWT>
```

Validation of this authentication is achieved utilizing the Passport framework with specific support for AAD and then
layered in front of all controllers through the use of a custom NestJS `AuthGuard` that ties these things together.

#### Authorization

Today there is no specific implementation of Authorization as the initial version of the system did not require locking
down any specific subset of resources. In the future it may be desireable to define Application Roles which can then be
validated on a per resource basis to limit access as required.

#### Courtroom Management API App Registration Settings

- Display Name: TFJ-Courtroom Management API
- Supported account types: Accounts in any organizational directory
- Authentication
  - No auth redirect URIs need to be configured, it's just an API and it doesn't
    do auth negotiation itself
- Expose an API
  - Application ID URI: `api://tfj/apis/courtroom-management`
  - Add Scopes:
    - `manage`
      - Who can consent: Admins only
      - Admin consent display name: Manage courts and related entities
      - Admin consent description: Grants the user the ability to manage courts
        and related entities.
  - Authorized Client Applications
    - Add each of the [Teams Application](#teams-applications) instances as authorized client applications
    - Authorize them for the `manage` scope
- API Permissions
  - MSGraph (delegated)
    - email
    - offline_access
    - openid
    - profile
- Certificates & secrets
  - Add secret
- Manual Manifest Settings
  - accessTokenAcceptedVersion: 2

> Note: Make sure to save the Azure AD App Registration Application Id and Secret
> somewhere, as you'd need them later.

### T4J App Instance

Every operational enviroment requires a unique application instance.
While you can usually share AAD Application Instances across environments as long as those environments are bound to the
same AAD tenant, that is not the case for a Teams Application. This is due to the fact that Teams requires the
application URI to include the IP address or domain name of the deployed application. Therefore an Application Instance
needs to be registered for each distinct IP/DNS of the environments we plan to deploy to.

#### T4J Application Instance App Registration Settings

- Display Name: T4J UI Application
- Supported account types: Accounts in this organizational directory only (Single tenant)
- Authentication
  - Add Platform
    - Web
      Redirect URIs: `https://<domain of deployed teams app>.azurewebsites.net/auth_end.html`, for example: `https://t4j-ui.azurewebsites.net/auth_end.html`
      - Select both `Access tokens` and `ID tokens` checkboxes
    - Single Page App
      Redirect URIs:
      `https://<domain of deployed teams app>.azurewebsites.net/blank-auth-end.html`, for example: `https://t4j-ui.azurewebsites.net/blank-auth-end.html`
      `https://<domain of deployed teams app>.azurewebsites.net/auth_end.html?clientId=<APP ID OF THIS APP REGISTRATION>`,
      for example: `https://t4j-ui.azurewebsites.net/auth_end.html?clientId=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`
  - Mobile and desktop
    - native client reply URL: `https://login.microsoftonline.com/common/oauth2/nativeclient`
- Expose an API
  - Application ID URI: `api://<domain of deployed teams app>/<APP ID OF THIS APP REGISTRATION>`,
  - for example: `api://t4j-ui-teamsapp.azurewebsites.net/<APP ID OF THIS APP REGISTRATION>`
  - Add Scopes:
    - `default`
      - Who can consent: Admins and users
        - Admin/User consent display name: anything... no one sees this except admin.
        - Admin/User consent description: anything... no one sees this except admin.
- Authorized Client Applications:
  - Add each of the [Teams Application](#teams-applications) instances as authorized client applications
    - Authorize them for the `default` scope
- API permissions
  - MS Graph (Delegated)
    - email
    - offline_access
    - openid
    - profile
    - User.ReadWrite.All (Admin Consent: yes)
  - TFJ-Courtroom Management API (Delegated)
    - manage (Admin Consent: yes)
- Certificates & secrets
  - Add a secret and store it somewhere. Later you will use this secret to store in the Azure KeyVault instance - this secret will be used by the API to exchange the ID token for an access
    token
- Manual Manifest Settings
  - accessTokenAcceptedVersion: 2

### Call Management Bot

The Call Management Bot requires an Application Identity in order to access Microsoft Graph to perform such actions as
retrieving online meeting data, establishing calls and manipulating participants within those calls.

#### Delegated Authentication of the Service Account

Most of the Graph APIs that the bot utilizes only require its Application Identity to invoke them. However, the bot also
needs to use some APIs (i.e. [Sending Chat
Messages](https://docs.microsoft.com/en-us/graph/api/chatmessage-post?view=graph-rest-1.0&tabs=http)) that require an
delegated User Identity to invoke them. In this case the bot is utilizing the [Resource Owner Password
Credentials (ROPC) flow](https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth-ropc) to obtain a
delegated Access Token for calling APIs with this requirement.

This means that the bot must be configured with the password of the Service Account in order to perform this
authentication flow. This is achieved by storing the password in Key Vault and referencing it via an App Setting.

#### Configuring the Service Account Settings in Teams

The Service Account that is used by the bot requires additional settings that need to be configured in Teams itself.
[These settings are documented here in the Setting Up a new Teams Tenant documentation](./setting-up-teams-tenant.md).

#### Call Management Bot App Registration Settings

- Display Name: TFJ-Call Management Bot
- Authentication
  - Add support for multi tenant
- Certificates & secrets
  - Add a Secret
- Expose an API
  - Application ID URI: `api://<domain, org or app name>/<APP ID OF THIS APP REGISTRATION>`,
  - for example: `api://t4j/<APP ID OF THIS APP REGISTRATION>`
  - Add Scopes:
    - `access_as_user`
      - Who can consent: Admins and users
        - Admin/User consent display name: anything... no one sees this except admin.
        - Admin/User consent description: anything... no one sees this except admin.
- Authorized Client Applications:
  - Add each of the [Teams Application](#teams-applications) instances as authorized client applications
  - Add the App Id for the `Teams for Justice Courtroom Management API` (created earlier) for the `access_as_user` scope
- API Permissions
  - MS Graph (Delegated)
    - ChatMessage.Send
    - User.Read
    - AppCatalog.ReadWrite.All (requires Admin consent)
  - MS Graph (Application, requires Admin consent)
    - Calendars.ReadWrite
    - Calls.AccessMedia.All
    - Calls.Initiate.All
    - Calls.InitiateGroupCall.All
    - Calls.JoinGroupCall.All
    - Calls.JoinGroupCallAsGuest.All
    - OnlineMeetings.Read.All
    - OnlineMeetings.ReadWrite.All
    - Chat.Read.All
    - Chat.ReadWrite.All
    - TeamsAppInstallation.ReadWriteForChat.All
    - TeamsAppInstallation.ReadWriteForTeam.All
    - TeamsTab.Create
    - TeamsTab.Read.All
    - TeamsTab.ReadWriteForChat.All
    - User.Invite.All
    - User.Read.All
- Manual Manifest Settings
  - accessTokenAcceptedVersion: 2

> Note: Make sure to save the Azure AD App Registration Application Id and Secret
> somewhere, as you'd need them later.
