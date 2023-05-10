# Teams for Justice Development

## Contents

- [Teams for Justice Development](#teams-for-justice-development)
  - [Contents](#contents)
  - [Azure Functions](#azure-functions)
    - [Extension Management](#extension-management)
  - [Development Container](#development-container)
  - [Building](#building)
  - [MEGA Linting](#mega-linting)
    - [Azure Storage Emulation](#azure-storage-emulation)

The below sections are for developers working on this solution:

This project has been configured to work best with [VS Code](https://code.visualstudio.com/). There are two ways to open
this project:

1. As a folder - simply open VS code from the root of the repository.
2. As a workspace - After opening as a folder, click on the dialog in the bottom right to open the workspace, or go to
   `File -> Open Workspace` and select the `workspace.code-workspace` file.

## Azure Functions

Running and debugging Azure Functions locally works best when running as a workspace; the workspace gives access to most
of the same code files, organized as projects. If a file is not present in the workspace, feel free to either it to the
workspace, or open as a folder for full access.

### Extension Management

Azure Functions that wish to interop with different Azure Services require bindings for those services. We are using an
explicit approach to manage these extensions to minimize the build times as well as to ensure we stay locked into the
versions of these bindings we know work well through testing.

If you are just working with existing code, there is nothing to do as we have a build step that will synchronize your
local project with the already configured extensions (i.e. runs `func extensions sync`) whenever you call `yarn build`.
If a new binding is necessary, the developer should either add this binding explicitly by referencing it in the
`function.json` file and calling `func extensions install` which will crawl the `function.json` files in the project,
discover all bindings used and update the `extensions.csproj` or manually install the extension using
`func extensions install -p <extension-package-name> [-v <version>]`.

For more on registering extensions, [please refer to this Azure Functions CLI documentation](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#register-extensions).

## Development Container

**Prerequisites:**

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [VS Code](https://code.visualstudio.com/)
- [Remote Development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

This project supports the use of [development containers](https://code.visualstudio.com/docs/remote/containers). Dev
containers are a great way to package all development requirements into a docker image and running VS code from the
context of that docker image. Dev containers can also be used with [Github
Codespaces](https://code.visualstudio.com/docs/remote/codespaces) for a hosted development environment.

To use the dev container, follow the [Quick Start
instructions](https://code.visualstudio.com/docs/remote/containers#_quick-start-open-an-existing-folder-in-a-container)
in the VS code documentation. VS Code will restart itself and open in the context of the docker container with your
local repo mounted directly into the container so you will not lose any work if the container stops.

## Building

**Pre-requisites**:

- [Node 14](https://nodejs.org/en/download/)
- Yarn (run `npm install -g yarn`)
- [Azure Functions Core Tools v3](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=linux%2Ccsharp%2Cbash)
  - Can be installed with `npm i -g azure-functions-core-tools@3 --unsafe-perm true`

All project source code is located in the `src` folder. This project utilizes [yarn
workspaces](https://yarnpkg.com/features/workspaces) to support all the projects as separate packages in a monorepo. To
install dependencies and build and test all the projects, run the following from the `src` folder:

```shell
yarn install        # installs all dependencies
yarn build          # builds all projects
yarn test           # run all unit tests
```

> Note: Your build may fail when building the `API` project due to the missing
> environment variable `TIME_ZONE_OPTIONS`. To fix it, clone the `.env.template`
> file in the same folder (`API`), then rename it into `.env`, and run the build
> again.

Using yarn workspaces means all dependencies are co-located in a single node_modules folder in the `src` folder. To run
any script present in a package.json for one of the projects within the workspace, you can use the following command:

```shell
yarn <project name> <command>
```

Or to run against all projects:

```shell
yarn workspaces run <command>
```

See [src/package.json](../src/package.json) for examples of this usage.

## MEGA Linting

**Prerequisites:**

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node 14](https://nodejs.org/en/download/)

This project uses a variety of linters to ensure code quality and style. Most of the linters are integrated into the VS
Code dev container or are recommended extensions. This project also uses the
[mega-linter](https://github.com/nvuillam/mega-linter/) to run linting for all PRs automatically via GitHub Actions.

This tool is automatically installed in the dev container; to install it on your local machine, run
`npm install -g mega-linter-runner`. To run the mega-linter locally, run `mega-linter-runner` in the root of the
repository. Configuration for the mega-linter can be found in `.mega-linter.yml`.

### Azure Storage Emulation

Several of the projects in this repo, such as the Azure Functions, are reliant on Azure Storage features to run.
[Azurite] solves this problem well for local development. Azurite can either be installed as a global tool using
[its `npm` package](https://www.npmjs.com/package/azurite) or as
[a container](https://hub.docker.com/_/microsoft-azure-storage-azurite) which you can spin up using Docker Desktop.
Documentation for how to work with each specific approach is provided at each of the respective links.

Then, in the project(s) that depends on Azure Storage, just make sure you set any Azure Storage connection strings
setting (e.g. `AzureWebJobsStorage`) in your configuration files (e.g. environment vars or appsettings) to the value:
`UseDevelopmentStorage=true`. This tells the SDK to specifically look for the emulator running on a specific set of
default ports.
