# API

TODO

## Getting started

Install any dependencies and set up your development environment. Then build,
run, and test the project.

### Setup

Some prerequisites to run this project:

- [Node](https://nodejs.org/en/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [Jest VS Code
  extension](https://marketplace.visualstudio.com/items?itemName=Orta.vscode-jest)
- [REST Client VS Code
  extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)

Create any Azure resources if they do not already exist, and save some values to
set up your local environment:

1. Create an [Azure Event Grid
   topic](https://docs.microsoft.com/en-us/azure/event-grid/custom-event-quickstart-portal):
   > **_Note:_** This requires enabling the [Event Grid resource
   > provider](https://docs.microsoft.com/en-us/azure/event-grid/custom-event-quickstart-portal#enable-event-grid-resource-provider)
   > which has been turned on for the T4J Azure subscription.
   1. Save the following values from your Event Grid topic:
      - The URL of the endpoint
      - One of the access keys
1. Create an [Azure
   CosmosDB](https://docs.microsoft.com/en-us/azure/cosmos-db/create-cosmosdb-resources-portal)
   resource:

   1. Save the following values from your CosmosDB resource:
      - The name of the resource
      - The URL of the endpoint from **URI** under **Keys**
      - One of the access keys taken from a connection string under **Keys**,
        for example
        `AccountEndpoint=<YOUR_AZURE_COSMOS_DB_ENDPOINT>;AccountKey=<YOUR_AZURE_COSMOS_DB_KEY>;`

1. Azure Event Grid Subscription (Webhook)

   The API subscribes to Event Grid to receive notifications of online meeting
   and calendar updates. To create an Event Grid subscription to an existing
   Topic on the command line use:

   ```bash
   az eventgrid event-subscription create --name <NAME-OF-SUBSCRIPTION> --source-resource-id $(az eventgrid topic show -g <RESOURCE-GROUP-NAME> -n <TOPIC-NAME> --query "id" -o tsv) --endpoint <API-URL>/hooks
   ```

   _See additional notes below on Event Grid webhooks_

Set up the local development environment:

1. Open your terminal to the `src/api` directory and run `yarn install`.
   > **_NOTE:_** The rest of this README assumes you are in the `src/api`
   > folder.
1. Open the repository in Visual Studio Code.
1. Copy `.env.template` into a new file that is named `.env`. Fill in the values
   as shown in the table below:

   | Variable                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
   | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
   | APPINSIGHTS_INSTRUMENTATIONKEY             | Azure application insights instrumentation key for logging. Will disable application insights logging when not defined                                                                                                                                                                                                                                                                                                                                                  |
   | AZURE_AD_REST_API_CLIENT_ID                | The client ID (aka application ID) of the Azure AD application that was created in the Azure AD tenant to represent the REST API.                                                                                                                                                                                                                                                                                                                                       |
   | AZURE_AD_REST_API_CLIENT_SECRET            | A client secret value belonging to the Azure AD application that was created in the Azure AD tenant to represent the REST API.                                                                                                                                                                                                                                                                                                                                          |
   | AZURE_AD_TEAMS_APP_CLIENT_ID               | The client ID (aka application ID) of the Azure AD application that was created in the Azure AD tenant to represent the Teams Client Application.                                                                                                                                                                                                                                                                                                                       |
   | AZURE_AD_TEAMS_APP_CLIENT_SECRET           | A client secret value belonging to the Azure AD application that was created in the Azure AD tenant to represent the Teams Client Application.                                                                                                                                                                                                                                                                                                                          |
   | AZURE_AD_TENANT_BASEURL                    | The base URL of the Azure AD tenant where the REST API application has been defined. Most commonly in the form of: `https://login.microsoftonline.com/<tenant-id>/`                                                                                                                                                                                                                                                                                                     |
   | AZURE_COSMOS_DB_ENDPOINT                   | The endpoint URL from your CosmosDB resource                                                                                                                                                                                                                                                                                                                                                                                                                            |
   | AZURE_COSMOS_DB_KEY                        | One of the access keys from your CosmosDB resource                                                                                                                                                                                                                                                                                                                                                                                                                      |
   | AZURE_COSMOS_DB_NAME                       | The name of your CosmosDB resource                                                                                                                                                                                                                                                                                                                                                                                                                                      |
   | CORS_ALLOWED_ORIGINS                       | A single domain name or comma separated list of domain names which are allowed to call the API. This should include the domain from which the Teams Application UI is being served.                                                                                                                                                                                                                                                                                     |
   | CORS_MAX_AGE_SECONDS                       | The number of seconds that the CORS policy should be considered valid by the client before it needs to do another pre-flight check. (Defaults to 15mins when not specified)                                                                                                                                                                                                                                                                                             |
   | EVENT_GRID_COURTROOM_EVENTS_TOPIC_API_KEY  | One of the access keys from your Event Grid topic                                                                                                                                                                                                                                                                                                                                                                                                                       |
   | EVENT_GRID_COURTROOM_EVENTS_TOPIC_ENDPOINT | The endpoint URL from your Event Grid topic                                                                                                                                                                                                                                                                                                                                                                                                                             |
   | EVENT_GRID_WEBHOOK_CLIENT_SECRET           | At the time of event subscription creation, Event Grid sends a subscription validation event to your endpoint. The data portion of this event includes a `validationCode` property. This validation code is randomly generated string that API application verifies that the validation request is for an expected event subscription, and returns the validation code in the response synchronously. This handshake mechanism is supported in all Event Grid versions. |
   | LOCAL_DEV_AUTH_SECRET                      | Allows specifying a secret value that must be supplied along with the local development auth header which just allows a little further security to be added when using that authentication scheme. When used, requests must supply an `Authorization` header that looks like: `LocalDevAuth <secret>` where the `<secret>` value matches this variable's value.                                                                                                         |
   | LOGGING_APP_INSIGHTS_LEVEL                 | `debug`, `info`, `warning`, `error` (<https://github.com/winstonjs/winston#logging-levels>). Will disable application insights logging when not defined                                                                                                                                                                                                                                                                                                                 |
   | LOGGING_CONSOLE_LEVEL                      | `debug`, `info`, `warning`, `error` (<https://github.com/winstonjs/winston#logging-levels>). Will disable console logging when not defined                                                                                                                                                                                                                                                                                                                              |
   | LOGGING_FILE_LEVEL                         | `debug`, `info`, `warning`, `error` (<https://github.com/winstonjs/winston#logging-levels>). Will disable file logging when not defined                                                                                                                                                                                                                                                                                                                                 |
   | LOGGING_FILE_MAX_FILES                     | The max number of log files to keep, default is `50` files                                                                                                                                                                                                                                                                                                                                                                                                              |
   | LOGGING_FILE_MAX_SIZE                      | The max size each log file, default is `10000` bytes                                                                                                                                                                                                                                                                                                                                                                                                                    |
   | LOGGING_FILE_NAME                          | The log file name, default is `api.log`                                                                                                                                                                                                                                                                                                                                                                                                                                 |
   | LOGGING_LEVEL                              | The logging level to override for all transports' level, default is `debug`                                                                                                                                                                                                                                                                                                                                                                                             |
   | LOGGING_SERVICE                            | The service name, default is `api`                                                                                                                                                                                                                                                                                                                                                                                                                                      |
   | NODE_ENV                                   | When set to `development`, this triggers the startup logic to load a certificate for localhost into the NestJS HTTP server.                                                                                                                                                                                                                                                                                                                                             |
   | PORT                                       | The port the API will listen on, default is `3001`                                                                                                                                                                                                                                                                                                                                                                                                                      |
   | AZURE_BLOB_STORAGE_ENDPOINT                | The endpoint URI for Azure blob storage. Should be in the form `https://{accountname}.blob.core.windows.net/`.                                                                                                                                                                                                                                                                                                                                                          |
   | AZURE_BLOB_STORAGE_EMAILS_CONTAINER        | The name of the blob storage container for email bodies.                                                                                                                                                                                                                                                                                                                                                                                                                |
   | BOT_API_URL                                | The URL of the Call Management Bot function API                                                                                                                                                                                                                                                                                                                                                                                                                         |
   | BOT_API_KEY                                | The API Key for the Call Management Bot API                                                                                                                                                                                                                                                                                                                                                                                                                             |

### Build

To build the project from your terminal, run `yarn build`.

### Generate SSL certificates

Before you can launch `API` project on your local machine, you must create and
add SSL certificate for localhost into your machine's Management Certificates
Store. Please follow the instructions in [Create Local Cert](./create-local-cert.md) document before moving to the next step.

### Run

To run the project from your terminal:

1. Navigate to the `src/api` directory and run `yarn start`. Wait for the server
   to start before moving on.
1. Open a new browser tab and navigate to the URL the API is running on, e.g.
   <https://localhost:3001>. You'll get a message that your connection isn't
   private.
1. Click **Advanced** and then click **Continue to `SOME_URL`** to approve the
   certification.

### Development

Here's a brief overview of core files:

This project uses [Nest Js framework](https://docs.nestjs.com/), Nest
[CQRS](https://docs.nestjs.com/recipes/cqrs) and Nest js
[Swagger](https://docs.nestjs.com/openapi/introduction).

- `main.ts`: The entry file of the nest js application which uses the core
  function NestFactory to create a Nest application instance.It uses
  [fastify](https://docs.nestjs.com/techniques/performance) and starts up HTTP
  listener, which lets the application await inbound HTTP requests.
- `app.module.ts`: The root module of the application.
- `controllers` folder: Nest [Controllers](https://docs.nestjs.com/controllers)
  are responsible for handling incoming HTTP requests and returning responses to
  the client.
- `commands` folder: Commands can be dispatched from the services layer, or
  directly from controllers. The CommandBus is a stream of commands. It
  delegates commands to the equivalent handlers
- `handlers/commands` folder: the corresponding Command Handler for each command
- `queries` folder: Queries can be dispatched from the services layer, or
  directly from controllers. The QueryBus is a stream of queries. It delegates
  queries to the equivalent handlers
- `handlers/queries` folder: the corresponding Command Handler for each query
- `events`: Events are asynchronous. events cen be emitted by using EventBus
- `handlers/events` folder: Each event can have multiple Event Handlers
- `events/integration-event-converters` & `handlers` folder: Nest
  [providers](https://docs.nestjs.com/providers) can be injected as dependency
  in `controllers`.
- `main-swagger.ts`: Nest provides [a dedicated
  module](https://docs.nestjs.com/openapi/introduction) which allows generating
  the OpenAPI specification to describe RESTful APIs specification by leveraging
  decorators. This file initializes Swagger using the `SwaggerModule`.
- `entities` folder: CosmosDB entities

### Debug

To debug the API from Visual Studio Code:

1. Open repository in workspace view. To do this from your terminal, navigate to
   the `src/api` directory and run `code workspace.code-workspace`.
1. Open the VS Code pane called **Run and Debug**.
1. Select the launch configuration called **Attach to api**.
1. Press **F5** to run the selected launch configuration.
1. Follow steps 2-4 from the [above guidance](#Run).

### Test

Now that the project runs successfully, you can unit test the system or send
test HTTP requests.

#### Test HTTP requests

With the project still running from before, send test requests using the [REST
Client VS Code
extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client):

1. Open [`api-test-requests.rest`](api-test-requests.rest) in Visual Studio
   Code.
1. Provide values for `courtroomId` and `courtId` as described in the file.
1. Click the link that says **Send Request** for the **createHearing** request.
1. Verify the request returns a `200 OK` response.
1. Now you can also send the **getHearing**, **editHearing**, and
   **deleteHearing** requests.

#### Unit tests

Run unit tests with Visual Studio Code debugging using the [Jest VS Code
extension](https://marketplace.visualstudio.com/items?itemName=Orta.vscode-jest):

1. Open Visual Studio Code in workspace view.
1. In Visual Studio Code, open the pane called **Run and Debug**.
1. Select the launch configuration called **vscode-jest-tests**.
1. Press **F5** to run the selected launch configuration.

Or, run the unit tests from your terminal with `yarn test`.

### Entities & Data Model

Entities used in this service is defined in the
[`src/api/entities/`](../../src/api/entities/) directory, with root level
entities named as `*.entitiy.ts` and referenced entities as `*.ts`. All entities
are documented in
[`docs/wiki/entities-and-terminologies.md`](../../docs/wiki/entities-and-terminologies.md),
please make sure the documentation is updated when you change anything under
this folder.

### Security

The REST API is secured in one of two ways:

1. With Azure AD Authentication which utilizes bearer JWTs
1. With a proprietary Local Development only authentication scheme that requires
   no more than a simple well-known header value (and optional secret).

#### Azure AD Authentication

This authentication mode is enabled by configuring the `AZURE_AD_TENANT_BASEURL`
and `AZURE_AD_REST_API_CLIENT_ID` environment variables.

When values are detected for these variables REST API will secure itself in a
way that requires all requests to provide a JWT utilizing the bearer
authentication scheme. This is accomplished by passing the HTTP `Authentication`
header like so:

```text
Authentication: Bearer <jwt>.
```

The claims inside of the JWT will then be used to derive the identity of the
user for the request.

#### Local Dev Authentication

This mode is completely proprietary and exists to speed the development inner
loop by not requiring any of the complications of Azure AD and/or procuring
fresh JWTs.

This mode is automatically enabled when the Azure AD Authentication mode is
_not_ activated via configuration.

This mode simply requires that clients pass a fixed value for the HTTP
`Authentication` header like so:

```text
Authentication: LocalDevAuth
```

For a little more security, the developer can configure the
`LOCAL_DEV_AUTH_SECRET` environment variable which can be set to any value the
developer chooses and then the `Authentication` header just needs to include
that value in addition to the default header value like so:

```text
Authentication: LocalDevAuth <secret>
```

### Event Grid Webhooks

The API receives events from an Event Grid subscription. As part of the
subscription process Event Grid will send a validation event to the endpoint
with a validationCode. The endpoint is required to echo this back in the
response body as a method of proof that the endpoint is valid.

For example requests see [api-test-requests.rest](./api-test-requests.rest)

### Developer Postman Setup

The following outlines Postman configuration for OAuth 2.O authorization code
flow to acquire an access_token which is required to use the API. The example
uses settings based on resources in the T4J Developer tenant

T4J Developer Tenant

- {{TenantId}} = F41ed3ee5-8a22-4b49-b49a-6b09bffea467

- {{clientId}} = ced5ea77-03ef-4a4f-966a-594c1c3e7083

The example {{clientId}} is currently named: `TFJ - Teams App - (INT1: tfj-api-int1.azurewebsites.net)`

Note that whatever client is used the Azure App registration must include
support for the Authentication Platform `Mobile and Desktop` to enable support
for the `https://login.microsoftonline.com/common/oauth2/nativeclient` Callback
Url

1. Create or Edit a Postman collection

1. **Authorization** Tab Settings

   | Setting          | Value           |
   | ---------------- | --------------- |
   | Type             | OAuth 2.0       |
   | Add auth data to | Request Headers |
   |                  |                 |

   **Configure New Token** section

   | Setting                 | Value                                                                                 |
   | ----------------------- | ------------------------------------------------------------------------------------- |
   | Token Name              | `environment name of token, e.g. dev:api`                                             |
   | Grant Type              | Authorization Code (with PKCE)                                                        |
   | Callback URL            | <https://login.microsoftonline.com/common/oauth2/nativeclient>                        |
   | Authorize using browser | un-checked                                                                            |
   | Auth URL                | <https://login.microsoftonline.com/{{TENANT_ID}}/oauth2/v2.0/authorize>               |
   | Access Token URL        | <https://login.microsoftonline.com/{{TENANT_ID}}/oauth2/v2.0/token>                   |
   | Client ID               | {{TEAMS_APP_CLIENT_ID}}                                                               |
   | Client Secret           | blank                                                                                 |
   | Code Challenge Method   | SHA-256                                                                               |
   | Code Verifier           | Automatically generated if left blank                                                 |
   | Scope                   | api://{{APPHOST}}/{{TEAMS_APP_CLIENT_ID}}/access_as_user user.read user.readbasic.all |
   | State                   | 123456                                                                                |
   | Client Authentication   | Send client credentials in Body                                                       |

Use [Get New Access Token] button to start the auth code flow
