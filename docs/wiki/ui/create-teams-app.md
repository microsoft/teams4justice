# Create Teams App

Teams apps are a combination of capabilities and entry points. For example, users can chat with the app's bot
(capability) in a channel (entry point).

> Note: This acts as a scaffolding and environment test. This simple tab does not currently connect to the backend API
> yet.

## Prerequisites

- [NodeJS](https://nodejs.org/en/)

- [Yarn](https://classic.yarnpkg.com/en/docs/install/)

- Your alias that has access to T4J Azure & Teams tenant. If you do not have one, please raise it in stand-up so we can
  get you one.

## Build and Run

Navigate to src/ui directory. In the ui directory, which contains (package.json) execute:

`yarn install`

`yarn start`

## Deploy to Teams

> Note: On the first time running and debugging the app you need allow the localhost certificate.
>
> - Open a new tab `in the same browser window that was opened`
> - Navigate to `https://localhost:6001`
> - Click the `Advanced` button
> - Select the `Continue to localhost`.

1. On a Teams channel, click the ... and select manage Teams.
1. Navigate to **Apps** and select **Upload a custom app**.
1. Upload the appPackage.zip.
1. Install(**Add**) upon prompted.
1. Go to any channel that you would like to install the tab.
1. Click the + icon, select the uploaded app (Default name: Justice Tab).
1. Click the **Save** button.

> Note: You can create your own appPackage.zip by compressing the contents in manifest directory, without
> **appPackage.zip**

## App Package

The manifest directory contains appPackage.zip which can be used to [sideload the tab
app](https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/deploy-and-publish/apps-upload) into Teams.

> Note: For quick testing purposes, you may directly sideload/upload the .zip to Teams.

It is strongly advisable to generate your own GUID and replace the id: field in manifest.json
