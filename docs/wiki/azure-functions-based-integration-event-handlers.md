# Azure Functions Based Integration Event Handlers

As an event driven system there will be many integration events being exchanged
between the various subsystems. We intend to leverage Azure Functions to consume
and process these events as it provides an excellent programming, deployment and
runtime model for doing so.

## Leveraging Azure Functions Event Grid Triggers

Azure Functions provides, via its extensibility model, support for registering
with Event Grid and receiving messages from Event Grid via its HTTP callback
mechanism. The Azure Functions programming model then requires that we
only define a simple function which is invoked whenever a new event is
delivered.

## Removing the Boilerplate

Since we are going to be writing many of these event handlers it would be good
to have some basic boilerplate in place that allows us to simply focus on the
code that needs to be written to handle the specific event and guarantee a
consistent experience across all handlers.

This boilerplate is be provided via a factory function called
`buildEventHandlerFunction` which is currently surfaced by importing
`@tfj/shared/integration-events` from the `@tfj/shared` package.

This factory takes care of the plumbing of the Azure Function and the basics of
an Event Grid based trigger binding to a simplified handler method signature
that abstracts just a bit from Azure Functions. The handler receives the
incoming `EventGridEvent<T>` and a `winston.Logger` which should be used for any
logging calls.

## Writing an Event Handler

A basic event handler function will look like this:

```TypeScript
export function thingCreatedHandler(
  eventGridEvent: EventGridEvent<ThingCreated>,
  logger: winston.Logger,
)
{
  // ...handler logic goes here...
}
```

Then you simply pass that to the `buildEventHandlerFunction` factory to wrap it up as an Azure Function:

```TypeScript
export const thingCreatedFunction = buildEventHandlerFunction(
  'ThingCreated',
  thingCreatedHandler,
);
```

Given this sample you then point to the `.js` file containing the exported
`const` and set the entry point to the variable name like so:

```JSON
{
  "bindings": [
    // Standard event grid trigger binding
    {
      "type": "eventGridTrigger",
      "direction": "in",
      "name": "eventGridEvent"
    }
  ],

  // Path to file that exports your function
  // (NOTE: .js from build output, not .ts from source)
  "scriptFile": "../dist/thing-created/thing-created.handler.js",

  // Name of export returned from factory
  "entryPoint": "thingCreatedHandler"
}
```

## Unit Testing an Event Handler

Because the `buildEventHandlerFunction` factory method handles and abstracts
away all the boilerplate of Azure Functions testing an event handler is even
simpler:

```TypeScript
// ... imports elided for brevity ...

describe('ThingCreated Event Handler', () => {
  const logger = winston.createLogger({
    transports: [new winston.transports.Console()],
  });

  it('should do something', async () => {
    const testThingId = uuid();

    await thingCreatedHandler(
      {
        id: uuid(),
        data: { id: testThingId, name: 'A Thing' },
        subject: `/things/${testThingId}`,
        dataVersion: 'v1.0',
        eventTime: new Date(Date.now()),
        eventType: 'ThingCreated',
      },
      logger,
    );

    // ... assertions here ...
```

> NOTE: technically you don't even need to create a real `winston` logger and
> could just use a mock/fake if you wanted
