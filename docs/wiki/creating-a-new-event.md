# Creating a New Event

In any event-driven system it is important to ensure all events are being delivered to the right sources as well as
contain the right data. This document goes over the steps to create a new event.

> Note: This is referencing any event that is managed by the Event Grid and not any internal events within the API CQRS
> system.

## 1. Create the Event interface

All events should be stored in the shared library so multiple sources (between the API and the various Azure Functions)
can access the same interfaces. The advantage of this is that it reduces the chances of a mismatch where one service
sends or receives one format that is different than the format a different service expects.

All integration events are stored in [`/src/shared/integration-events`](../../src/shared/integration-events). Each event
should be an interface so we are able to take advantage of TypeScript's duck typing.

> Reminder: Add your recently created interface to the [`index.ts`](../../src/shared/integration-events/index.ts) file
> so it gets exported!

## 2. Use the Event

Each of our services can either send or receive events, but the way they do that differs between the services.

### API (NestJS CQRS)

Our REST API internally uses the NestJS CQRS module which makes integration with an event driven system seamless. In
general, internal events can get converted to integration events before being sent out to the event grid, or integration
events enter the system and get converted to internal events.

#### Sending Event Grid Events

To send an event to the event grid, an "integration event converter" needs to be written which converts the internal
event into the interface defined in the previous step. All integration event converters should be stored in
[`src/api/events/integration-event-converters`](../../src/api/events/integration-event-converters/). To build a
converter, use the `buildIntegrationEventConverterHandler` function which returns the actual function.
`buildIntegrationEventConverterHandler` takes in an event and a lambda function which maps the values from that event
into an `OutboundEventGridEvent`. This `OutboundEventGridEvent` takes a generic parameter which specifies the event type,
in this case it should match the type created in the previous step.

> IMPORTANT: Ensure that the new converter handler function is added to
> [`IntegrationEventConverters`](../../src/api/events/integration-event-converters/index.ts), otherwise it will not
> resolve the handler and the internal event will be left unhandled.

Once the handler is configured, all internal events that are published to the event bus will be automatically converted
and sent out to the Event Grid!

#### Receiving Event Grid Events

Receiving an event grid event in the API is very similar to sending it. Instead of using
`buildIntegrationEventConverterHandler` as the handler factory, instead use `buildIncomingIntegrationEventConverter`.
This handler does the opposite - it takes an integration event and returns an `IEvent` that then gets processed by the
internal CQRS event bus.

The main entry point for events into the REST API is the event grid controller - its main purpose is to call the correct
incoming integration event converter and then publish the correct internal event.

### Azure Functions

Azure Functions handles much of the event grid specific work for us. Using an [event grid
trigger](https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-grid-trigger?tabs=javascript%2Cbash)
we can send or receive events from the event grid easily.

As a convenience, there is a similar factory method to the API event grid converter handlers available for Azure
Functions usage. `buildEventHandlerFunction` creates and returns an Azure Function that runs a given handler. The
handler is given an event as input and can optional return an event as output. In the case of Azure Functions, both
events should be present in the `shared/integration-events` folder.

## 3. Create the Event Grid Subscription

If this event is being consumed by an Azure Function or the web hook in the REST API, an event grid subscription needs
to be created so the Event Grid can route the events to the right resources. All event grid subscriptions are stored in
the terraform code. The subscriptions differ a bit between the two code locations though.

### 3a. API Event Grid Subscription

Since the REST API has a single webhook endpoint for all events, a new subscription does not need to be created for each
event. Instead, the new event type should be added to the existing filters so that the message is correctly routed.

To do that, modify the `module.subscriptions` resource present in the [`api_post`](../../terraform/api_post/main.tf)
script. Add the new event type to the `type_filters` array in the `endpoint` argument for it to be added to the filters.

### 3b. Azure Function Event Grid Subscription

Each Azure Function requires its own subscription for the event grid to properly route the events. The specifics of this
will depend on the exact service that is being deployed.

For most subscriptions, modify the `module.subscriptions` resource present in the `*_post` terraform script. Add the new
subscriptions to the `subscriptions` key in the `endpoint` argument. The key must match the name of the Azure Function.
Optional `type_filters` and `advanced_filters` can be added to the value of map to filter for that subscription.

For example:

```terraform
module "subscriptions" {
  source = "../modules/event_grid_subscriptions"

  eventgrid_topic_id = data.azurerm_eventgrid_topic.this.id
  name_prefix        = "my-function-app"

  endpoint = {
    function_app_id = data.azurerm_linux_function_app.my_function_app.id
    subscriptions = {
      "my-function" = {
        type_filters     = ["type_filter"],
        advanced_filters = {
          string_in = {
              key = "data.my_key_to_filter_on"
              values = ["Array", "of", "allowed", "values"]
          }
        }
      }
    }
  }
}

```

## 4. PR and Merge

The terraform scripts will not be run until the PR is merged, but the PR pipeline will format and validate your changes
ahead of time.
