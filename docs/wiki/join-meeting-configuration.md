# Join Meeting

When Bot receives the request to join the scheduled online meeting, the number of prerequisite steps must be performed
in order to enable this functionality. These steps are provided in this document.

## Permissions

One of the following **Application** permissions (from least to most privileged) is required to call this API. To learn
more, including how to choose permissions, see
[Permissions](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/calls-and-meetings/registering-calling-bot#add-microsoft-graph-permissions).

- Calls.JoinGroupCallsasGuest.All
- Calls.JoinGroupCalls.All
- Calls.Initiate.All
- Calls.InitiateGroupCalls.All

## Allow Bot to access online meetings on behalf of a Service Account

To configure an application access policy and allow Bot application instance to access online meetings with application
permissions, perform the following steps:

1. Identify the Bot app’s application (client) ID and the user IDs of the Service Account on behalf of which the Bot
   will be authorized to access online meetings.
2. Connect to MicrosoftTeams PowerShell with an administrator account.
3. Run the following cmdlet, replacing the Identity, AppIds, and Description (optional) arguments.

   ```powerShell
   New-CsApplicationAccessPolicy -Identity Bot-access-policy -AppIds "ddb80e06-92f3-4978-bc22-a0eee85e6a9e", "ccb80e06-92f3-4978-bc22-a0eee85e6a9e", "bbb80e06-92f3-4978-bc22-a0eee85e6a9e" -Description "description here"
   ```

4. Grant the policy to the Service Account to allow the Bot IDs contained in the policy to access online meetings on
   behalf of the granted user. Run the following cmdlet, replacing the PolicyName and Identity arguments.

   ```powerShell
   Grant-CsApplicationAccessPolicy -PolicyName Bot-access-policy -Identity "ddb80e06-92f3-4978-bc22-a0eee85e6a9e"
   ```

> Note

- Identity refers to the policy name when creating the policy, but the user ID when granting the policy.
- Changes to application access policies can take up to 30 minutes to take effect in Microsoft Graph REST API calls.
