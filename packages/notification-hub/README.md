# Notification hub

This is a TypeScript/Node Azure Functions project with HTTP-triggered functions that will translate events into SignalR
messages that are broadcast to all connected client UIs.

## Getting started

Install any dependencies and set up your development environment. Then build, run, and test the project.

### Setup

Some prerequisites to run this project:

- [Node](https://nodejs.org/en/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [REST Client VS Code extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client)
- [Azure Functions Core
  Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#install-the-azure-functions-core-tools).

Create any Azure resources:

1. Create an [Azure SignalR
   Service](https://docs.microsoft.com/en-us/azure/azure-signalr/signalr-quickstart-azure-functions-javascript#create-an-azure-signalr-service-instance),
   or use an existing one.
1. Save the value of the connection string from your Azure SignalR resource to set up your local environment.

Set up the local development environment:

1. Open your terminal to the `src/` folder of the repository and run `yarn install`.
1. Open the repository in Visual Studio Code.
1. Copy `local.settings.template.json` into a new file that is named `local.settings.json`. Fill in the
   `AzureSignalRConnectionString` value with the connection string from your Azure SignalR Service.
1. Fill in the `AzureWebJobsStorage` value with the storage connection string for Azure Function, or if locally running
   Azurite, set to `UseDevelopmentStorage=true`

| Variable                     | Description                                                                                                                              |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| AZURE_AD_ISSUER_URL          | The issuer URI that should be expected in the JWT that accompanies calls notifications.                                                  |
| AZURE_AD_REST_API_CLIENT_ID  | The client ID of the application registered in Azure AD representing the API                                                             |
| AZURE_AD_JWKS_URL            | The URL that points to the JWKS endpoint containing the signing keys for the JWT that accompanies calls notifications.                   |
| AZURE_AD_JWKS_CACHE_MINUTES  | The number of minutes to cache the JWKS signing keys. Once the cached keys are stale, they will be re-downloaded from the JWKS endpoint. |
| AZURE_AD_AUTH_DISABLED       | Allows for disabling signalr authentication checks for _local development only_.                                                         |
| AzureSignalRConnectionString | Connection string to the Azure SignalR service                                                                                           |

### Build

Build the project from your terminal:

1. Open your terminal to the `src/` folder of the repository.
1. Run `yarn workspace notification-hub run build` to build the project.

### Run

To run the project with Visual Studio Code debugging:

1. Open Visual Studio Code in workspace view. To do this from your terminal, run `code workspace.code-workspace` from
   the root of the repository.
1. In Visual Studio Code, open the pane called **Run and Debug**.
1. To run only this project, select the launch configuration called **Attach to notification-hub**. Or, to run all 5
   Functions projects in parallel, choose **Attach to all Functions apps**.
1. Press **F5** to run the selected launch configuration.

Or, to run the project from the command line:

1. Open your terminal to the `src/` folder of the repository.
1. Run `yarn workspace notification-hub run start` to start the project.

### Test

Now that the project is running, test that the project works using the [REST Client VS Code
extension](https://marketplace.visualstudio.com/items?itemName=humao.rest-client):

1. In your browser, navigate to
   <https://azure-samples.github.io/signalr-service-quickstart-serverless-chat/demo/chat-v2/>.
1. Open [`NotificationHubTestRequests.rest`](NotificationHubTestRequests.rest) in Visual Studio Code.
1. Click the link that says **Send Request** for the **negotiate** request.
1. Verify the request returns a `200 OK` response.
1. Click the link that says **Send Request** for the **sendMessage** request.
1. Verify the request returns a `204 OK` response and that the request body appears on all instances of the client
   running that are using the same `AzureSignalRConnectionString`.
