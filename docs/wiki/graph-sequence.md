# Execution sequence for graph flow

The following sequence diagram illustrates the control flow for the Call Management Bot component which is responsible
for interacting with the Microsoft Graph APIs.

---

**NOTE:** This sequence only captures the existing asynchronous control flow
initiated from the APIs to the Call Management Bot via the event grid.

---

<!-- generated by mermaid compile action - START -->

![~mermaid diagram 1~](../images/docs_wiki_graph-sequence-md-1.png)

<details>
  <summary>Mermaid markup</summary>

```mermaid
sequenceDiagram %% diagram
  %% participant
  participant Eve as Event Grid
  participant Fac as Event Handler Factory<br>(buildEventHandlerFunction)
  participant EveH as Event Handler
  participant GC as Graph Client
  participant ID as Microsoft Identity Provider
  participant MG as Microsoft Graph APIs
  activate Eve
  %% Event Published
  Eve->>Fac: Event Published
    %% Instantiate handler
    activate Fac
  deactivate Eve
    Fac->>EveH: Create concrete implementation
    deactivate Fac
      %% Handle event
      activate EveH
      EveH->>EveH: Build Graph Object
      EveH->>GC: Call Graph client
        %% Invoke graph client
        activate GC
        GC->>ID: Get access token
          activate ID
          ID-->>GC: Access Token
          deactivate ID
          GC->>MG: Call Graph API
            activate MG
            MG-->>GC: Graph API Response
            deactivate MG
          GC-->>EveH: Graph API Response
        deactivate GC
        EveH->>EveH: Create response (integration) event object
        EveH-->>Eve: Publish response event
        activate Eve
        Eve->Eve: Publish event to subscribers
        deactivate Eve
      deactivate EveH


```

</details>
<!-- generated by mermaid compile action - END -->