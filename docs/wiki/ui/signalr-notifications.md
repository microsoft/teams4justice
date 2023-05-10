# SignalR Notifications

SignalR is a technology that uses web sockets to easily update clients based on updates in the server, or vice-versa. It
was used in this project to push updates to the UI based on Event Grid events.

## Server Architecture

The SignalR Implementation is made up of 2 distinct services: An Azure Function app that contains the business logic to
send messages to the UI and the Azure SignalR Service which manages the connections with the clients. Since SignalR
connections are open websocket connections, that would normally mean requiring lots of server nodes to maintain
connections with the clients, but the SignalR Service abstracts all that away and allows for easy scaling independent of
our app service plan.

The SignalR Service runs in a ["serverless"
mode](https://docs.microsoft.com/en-us/azure/azure-signalr/signalr-concept-azure-functions), which means that clients
first "negotiate" a connection with our serverless function, and as a part of the handshake, a connection URL is passed
to the client along with an access token for accessing the SignalR Service endpoint. From then on, the serverless
function can simply post messages to the SignalR service and it manages all communication with the client.

There are 3 distinct types of functions running in the Notification Hub Azure Function app:

1. `negotiate` - handles authentication and handshake with the user.
2. `subscribe`/`unsubscribe` - allows users to subscribe to notifications for a specific case ID
3. Notification functions - The functions that convert Event Grid events to SignalR messages (as of this writing, there
   is a single function `case-room-participant-changed` but additional functions can be added).

All of the above functions use the [SignalR Service bindings] for Azure Functions to simplify development:

1. `negotiate` uses a [SignalR Input
   binding](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-signalr-service-input?tabs=javascript)
   to expose the SignalR Service data to the Azure Function for it to be passed down to the client.
2. `subscribe`/`unsubscribe` are HTTP triggered functions that use a [SignalR Output
   Binding](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-signalr-service-output?tabs=javascript#group-management)
   for Group Management. Clients must POST to this address specifying the case ID they wish to receive notifications for
   as a part of the route.
3. Notification Functions are Event Grid triggered functions that use a [SignalR Output
   Binding](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-signalr-service-output?tabs=javascript#send-to-a-group)
   to send Group messages. Their purpose is to simplify the Event Grid data object to the minimal set required to send
   to the clients and then return those messages to the SignalR service for broadcasting.

## Client Implementation

SignalR access is provided to all components in the UI via the [`SignalRProvider`
Context](../../../src/ui/src/components/signalr/SignalRProvider.tsx). In order to connect to
the SignalR server, a component only needs to use the context hook:

```typescript
import { useSignalRContext } from "../signalr";

const { isReady, connection, isError } = useSignalRContext();
```

The `isReady` flag is set when the SignalR connection has been successfully established and negotiation has been
completed. The `connection` object is an instance of the SignalRConnection class which wraps around all the SignalR
library as well as provides access to the `subscribe` and `unsubscribe` endpoints.

To subscribe to a case ID, call the `subscribeToCaseNotifications` function. It is recommended to do this in a
`useEffect` block based on whether or not `isReady` is true. After subscription is successful, we can ask to listen to
certain message types:

```typescript
React.useEffect(() => {
  if (isReady && connection !== undefined) {
    connection.subscribeToCaseNotifications(caseSummaryModel.id).then(() => {
      connection.startListen("caseRoomParticipantChanged", updateParticipants);
    });

    return () => {
      connection.stopListen("caseRoomParticipantChanged");
      connection
        .unsubscribeToCaseNotifications(caseSummaryModel.id)
        .catch(() => {});
    };
  }

  return () => {};
}, [caseSummaryModel, connection, isReady, updateParticipants]);
```

In the above example, `updateParticipants` is a callback that takes a single parameter which is the payload of the
SignalR message, and returns void. That method will be automatically called every time a message is received by the
client once `startListen` has run. In this case, updateParticipants will update the state of the component to either add
or remove participants based on the notification.

To clean-up, we stop listening and unsubscribe when the component is unloaded.

> Note: SignalRProvider is currently scoped only around the `HearingControl` component to prevent unnecessary calls, if
> adding SignalR functionality in the UI, the provider should be moved in `App.tsx` so that all downstream routes have
> access to it.

## Future Improvements

Additional Notification Functions can be added by utilizing the `buildNotificationHandler` method. This function
generates an Azure Function compatible function but abstracts some of the Azure Function specifics for easy testing.

The `subscribe` and `unsubscribe` methods currently only allow grouping on case ID, but that may want to be expanded to
support courtrooms and hearings.

### Example Areas Where Notifications Can Be Added

- In the Calendar view, clients can be notified of new or edited calendar events.
- In the Private Rooms view, clients can be notified of participants leaving and joining the different views.
- In the Calendar and Private Rooms views, clients can be notified of Online Meeting information being available.
