# Teams Application Principles and API Dependencies

Teams for Justice is a first party Teams application and it therefore relies on various capabilities of Microsoft Teams
to facilitate its operation.

Solution Principles:

- Enables Moderators within Microsoft Teams – a cohesive, single application and execution point for online hearings
- A single high fidelity Microsoft Teams application
- We use a Team to represent a court and channels to represent courtrooms – we work with existing AD users
- The Microsoft Teams application can be configured/setup from outside of Microsoft Teams (by court IT staff)
- We enable functionality through a a lightweight architecture that is easily supported and extended
- Azure Services can be deployed to a single or, where possible, common Azure tenancy ( to maximise support effectiveness)

There are changes that have been widely reported on platform changes for Microsoft Teams. For example:

- Angular to REACT ([slides](http://slides.com/abhikmitra/teams-react/fullscreen#/37))
- “Maglev” [link 1](https://www.windowscentral.com/microsoft-teams-could-become-lot-faster-new-app-windows-10)
- "Maglev" [link 2](https://www.windowslatest.com/2021/07/14/our-first-look-at-new-microsoft-teams-for-windows-10-and-windows-11/)

These changes should have no impact on this solution. New APIs are continually being added to Team.
An example are [new Media APIs](https://techcommunity.microsoft.com/t5/microsoft-teams-blog/microsoft-teams-announces-new-developer-features-build-2021/ba-p/2352558)).

The service dependencies we build upon are a very low probability to be removed:

1. The [Microsoft Teams JavaScript client SDK](https://www.npmjs.com/package/@microsoft/teams-js)
1. [Fluent UI - React Northstar](https://github.com/microsoft/fluentui/tree/master/packages/fluentui/react-northstar) \*
   this library has concepts Microsoft is iterating on.
1. [Microsoft Graph v1.0](https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-1.0) (e.g. invitations,
   AD and calendar)

To mitigate any development issues we have pinned the version being used so it won't affect any service calls.
