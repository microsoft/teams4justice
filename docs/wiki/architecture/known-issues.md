# Known issues

This document captures the know issues in the solution.

## Idempotency using event grid

This solution leverages Azure Event Grid to deliver events across subsystems. The event grid is used to implement the
[Observer pattern](https://docs.microsoft.com/en-us/dotnet/standard/events/observer-design-pattern) as there can be
multiple subscribers for an event.

### Risk

The message delivery policy for the Azure Event grid is ['at least once'](https://docs.microsoft.com/en-us/azure/event-grid/delivery-and-retry)
which means that every event will at least be
delivered once to every subscriber unless it becomes a dead letter. This policy is very effective to handle transient
failures of the subscribers as the Event Grid will keep retrying the delivery till the subscriber acknowledges.

However, this demands the subscribers to be idempotent to ensure duplicate events are handled gracefully. In the case of
API subscribing to events from the call management subsystem, the idempotency is not fully implemented. This can cause
an unstable state in the frontend system if duplicate events are published by the Event Grid.

### Analysis

As per research, it is highly unlikely for the Event grid to publish a duplicate event due to any internal circumstances.
The most probable reason for an event to be published again is if the subscriber fails to handle the event or is
unavailable. In such cases repeating the event is the desired action and will not impact the stability of the system.

### Potential Fix

A potential fix is to implement idempotency at the API layer when an integration event is converted
(buildIntegrationEventConverterHandler) by storing a state around the last received event and its status of processing.

[Outbox pattern](https://www.kamilgrzybek.com/design/the-outbox-pattern/) can provide guidance on such an implementation.

Replacing Event Grid with [Service Bus Topics](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-messaging-overview)
is also a potential fix. This however requires careful consideration about
scalability requirements.
