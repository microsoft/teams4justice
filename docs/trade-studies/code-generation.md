# Trade Study: Code Generation for Client-Side APIs

|                 |                                             |
| --------------: | ------------------------------------------- |
| _Conducted by:_ | Omeed Musavi                                |
|  _Sprint Name:_ | Sprint 0                                    |
|         _Date:_ | 4/8/2021                                    |
|     _Decision:_ | Use NSwag for code generation               |
|      _Updated:_ | 4/21/2021                                   |
| _New Decision:_ | NestJS for OpenAPI; AutoRest for TypeScript |

- [Trade Study: Code Generation for Client-Side APIs](#trade-study-code-generation-for-client-side-apis)
  - [Overview](#overview)
    - [Update 4/21/2021](#update-4212021)
  - [Goals](#goals)
  - [Open questions](#open-questions)
  - [Generating OpenAPI JSON File from ASP.NET Core Web API](#generating-openapi-json-file-from-aspnet-core-web-api)
    - [Using NSwag](#using-nswag)
  - [Generating a client-side Typescript library from OpenAPI definition](#generating-a-client-side-typescript-library-from-openapi-definition)
    - [AutoRest](#autorest)
      - [Pros](#pros)
      - [Cons](#cons)
    - [NSwag](#nswag)
      - [Pros](#pros-1)
      - [Cons](#cons-1)
    - [swagger-codegen](#swagger-codegen)
    - [openapi-generator](#openapi-generator)
  - [Repository Organization Considerations](#repository-organization-considerations)
    - [Generated code location](#generated-code-location)
      - [Single Workspace](#single-workspace)
      - [Multiple Workspaces](#multiple-workspaces)
      - [Decision](#decision)
    - [When to run code generation](#when-to-run-code-generation)
      - [Generate clients on PR builds](#generate-clients-on-pr-builds)
      - [Generate clients on main builds with an automated PR](#generate-clients-on-main-builds-with-an-automated-pr)
      - [Decision](#decision-1)
  - [Recommendations](#recommendations)

## Overview

In an effort to increase developer velocity, it was brought up that using the OpenAPI definition of the REST API we
can generate the client side code to make the requests. There were several different investigations done to determine if
this was not only viable for this solution but also how it would be configured to work with our existing systems.

### Update 4/21/2021

Since this document was written, the decision was made to move from .NET Core to TypeScript for the REST API backend.
This does not affect the findings of this document for OpenAPI -> TypeScript but it does affect how we generate OpenAPI
documents.

Since we are using NestJS for the Web API Framework, we will utilize the recommended way of generating the OpenAPI JSON
file [through their documentation](https://docs.nestjs.com/openapi/introduction). There is also a [GitHub
comment](https://github.com/nestjs/swagger/issues/110#issuecomment-527455775) that indicates a way to generate the JSON
file without requiring the server to be run (by having a second `main` method). We will use this approach to generate
the OpenAPI JSON file.

Also as a result of this change and since we are no longer using the dotnet toolchain, we will no longer use NSwag and
instead use AutoRest for the TypeScript generation since it is build on Node.

## Goals

- Determine which library to use to generate OpenAPI JSON file.
- Determine if generating a client side TypeScript library from the OpenAPI definition will work for our solution.
- Determine how to integrate client generation into our CI pipelines.
- Determine how to organize code to reduce dependency errors and create bugs.

## Open questions

- How authentication model of AutoRest can integrate with the way we acquire Teams authentication tokens

## Generating OpenAPI JSON File from ASP.NET Core Web API

Both [NSwag](https://github.com/RicoSuter/NSwag) and
[Swashbuckle](https://github.com/domaindrivendev/Swashbuckle.AspNetCore) are [recommended in the
documentation](https://docs.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger?view=aspnetcore-5.0).
For our solution we are looking for the following functionality:

- Generating an OpenAPI JSON file from the Web API endpoints without requiring a deployment to view
- Easily add the Swagger UI for developer testing

Both NSwag and Swashbuckle fit both of our required criteria. The only major differentiator that jumped out was that
NSwag comes with MSBuild targets which can easily fit into our MSBuild rules, as opposed to Swashbuckle which uses
`dotnet tool`. For this reason NSwag was chosen as our preferred method of generating the OpenAPI definition, though
if further requirements are added later, Swashbuckle will be a perfectly valid solution.

### Using NSwag

To configure NSwag to fit our requirements, the following needs to be added to our Startup.cs:

```csharp

public void ConfigureServices(IServiceCollection services)
{
    /// other services configured above...
    services.AddOpenApiDocument();
}

// This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
    /// other app settings configured...

    /// Must be before UseRouting
    app.UseOpenApi();
    app.UseSwaggerUi3();

    app.UseRouting();

    /// other settings...
}
```

Our build rules must also be modified to add the NSwag.MSBuild reference, and then the following build target:

```xml
  <Target Name="NSwag" AfterTargets="Build">
      <Exec EnvironmentVariables="ASPNETCORE_ENVIRONMENT=Development" Command="$(NSwagExe_Core30) aspnetcore2openapi /assembly:$(TargetDir)$(AssemblyName).dll /output:serveropenapi.json" />
  </Target>
```

Additionally, the following property should be added:

```xml
<PropertyGroup>
    <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>
</PropertyGroup>
```

## Generating a client-side Typescript library from OpenAPI definition

Generating Typescript code from the OpenAPI definition could be done through several different technologies:

- [AutoRest](https://github.com/Azure/autorest.typescript) - Azure supported library for generating from OpenAPI
- NSwag - contains a [TypeScriptClientGenerator](https://github.com/RicoSuter/NSwag/wiki/TypeScriptClientGenerator) that
  can be used in the command line (or via the dotnet core build if desired)
- [swagger-codegen](https://github.com/swagger-api/swagger-codegen) - supported by Smartbear (swagger owners)
- [openapi-generator](https://github.com/OpenAPITools/openapi-generator) - fork of swagger-codegen meant to be more
  community oriented.

The requirements for our solution are:

- Generates an easy to use class that mirror the API
- Works with async promises
- Supports authentication tokens
- Easy to integrate into our toolchain

### AutoRest

AutoRest generates not only the client code, but is also capable of generating the metadata required to make the entire
client its own NPM package. This could be really useful especially in the case of micro-repos where a code change in one
repo could automatically create a PR and publish a new NPM package all automatically. Consumers of the package could
then manually update their NPM dependencies.

For simplicity in this project we are likely going to be working in a monorepo, which negates some of those benefits.
AutoRest does support generating just the client code.

AutoRest uses YAML blocks within a markdown file (like README.md) to contain the settings for the client generation. An
example AutoRest configuration file we could use for our project is below:

````yaml
```yaml
title: ClientApi
input-file: ../server/serveropenapi.json
typescript: true
output-folder: ./lib
add-credentials: true
clear-output-folder: false
generate-metadata: false
package-name: client-api      # use if generate-metadata: true, this is the package name in package.json
```
````

The above block would create a client class named `ClientApi` in the `lib` folder. It would support credentials being
passed in via the `@azure/identity` library. `clear-output-folder` ensures that between runs of AutoRest, everything is
regenerated. Since `generate-metadata` is set to `false`, it would just generate the typescript files and not treat it
as its own library. Setting this value to `true` would generate a `package.json` file, as well as other package files
such as `README.md`, `.npmignore`, and webpack configuration.

One of the advantages of AutoRest is it's Azure integration; it uses Azure libraries like `identity`,
`core-http`, and supports things like generating a client that can have ARM access to create resources. It also
organizes the code between `models` and `operations` folders. The main entry point to the library is through a single
class where all other operations can be accessed, so the baseURL and credentials only need to be passed in once.

For the purposes of this project, we do not currently need any direct Azure integration, especially since we would get
the token directly from a Teams API and not the usual Azure Identity service providers, so we do not gain too much from
using those settings.

AutoRest is available as an npm package and can be run without installing using npx:

```console
npx autorest README.md
```

#### Pros

- Supports both library generation and simple code generation
- Azure integration could potentially simplify auth story.
- Supports long running polling and paging out of the box.
- Easy to run in CI pipeline with `npx`.

#### Cons

- Limited extensibility of generated classes

### NSwag

NSwag also contains client generation code for many languages, but one neat feature that the
[Typescript](https://github.com/RicoSuter/NSwag/wiki/TypeScriptClientGenerator) has is that it supports multiple
different library "templates" to actually make the HTTP calls. In our cases we would probably want to use Fetch or Axios
(in preview), but it also supports Angular and JQuery.

NSwag generates all of the clients into a single output file. It has methods for then extending the functionality of
those generated classes using inheritance. It also supports adding headers, and has some [special methods for adding
auth headers in
particular](https://github.com/RicoSuter/NSwag/wiki/TypeScriptClientGenerator#inject-an-authorization-header), which
requires some settings in the nswag.json file (a configuration file that requires the NSwagStudio GUI to generate).

Clients that are generated are separated by operation/API, even if they use the same base URL.

Running NSwag as a `dotnet tool` is an easy way to generate the clients. An example command line operation would be:

```console
nswag openapi2tsclient /input:server/serveropenapi.json /output:client/ui/server.ts /template:axios
```

#### Pros

- Supports multiple HTTP libraries, could be easier to integrate into existing code.
- Easily extend generated clients
- Easy to run in CI pipelines as a `dotnet tool`, or through the MSBuild package to be run during the server build.

#### Cons

- Requires NSwagStudio GUI for more complex configuration options (generating the nswag.json file if necessary).

### swagger-codegen

Swagger-codegen is maintained by Smartbear, the owners of the Swagger brand, so it is well maintained and supports
generation into TypeScript. Unfortunately, it is primarily used through Java or Docker, and since we are not using
either, it would require another installed prerequisite for our development environment, so it was not considered.

### openapi-generator

A community-owned fork of swagger-codegen, but it also includes an npm module. JVM is still required to be installed
though, so again not considered due to Java or Docker requirement.

## Repository Organization Considerations

Both AutoRest and NSwag are completely capable of generating the clients we would be able to use for this project. There
is still a question on how the generated clients would be integrated into our codebase and the way it would fit into the
larger CI pipelines.

### Generated code location

There are two possibilities for integrating the generated code into our codebase.

#### Single Workspace

In this case we would likely have a folder within our existing UI project that would contain all the generated client
code. Both AutoRest and NSwag support generating code to a specific destination. Code in the UI library could then very
easily import the generated code and execute on it.

The downside of this approach is that is tightly couples our clients with our UI implementation.

#### Multiple Workspaces

One possible way to organize the generated code is to have it isolated in its own package. AutoRest already supports
generating the code with all the scaffolding required for a package, but adding it to NSwag would be as simple as
configuring the proper package.json values.

The main issue with having the generated code in its own package comes down to dependency management in a monorepo. In
general, the biggest disadvantage of a monorepo is controlling dependencies. To solve this issue, one option is to use
[yarn workspaces](https://classic.yarnpkg.com/en/docs/workspaces/), which provides an easy and more dependable solution
than just symlinking packages together. This also allows multiple projects to share dependencies and a single install
point as opposed to a `node_modules` in each package folder.

For the purposes of this project, since CMS integration is an extension point, it could make sense that we may want to
client packages for future use, so keeping the libraries completely separate could be beneficial. It also allows for a
very clear delineation between code that is generated and code that is hand-written.

#### Decision

To promote decoupling and the potential for shipping the clients as packages, we should build the clients into their own
npm package and use yarn workspaces to reference them within our monorepo.

### When to run code generation

Since this project is in a monorepo, there is a possibility that a breaking change in the server code would cause build
errors in the client code. A breaking change will need to still be dealt with, but requiring all local code changes for
a server to also build and test the client code makes for a poor developer experience. The alternative however would
mean that server code and client code could potentially be out of sync and not functional.

#### Generate clients on PR builds

This is the safest way to ensure that our server code and our generated clients are always in sync with each other.
However, this does mean a breaking change in the server code would break the consumers of the generated clients.

The process of generating the clients can be automated by running the client generation scripts on the CI build machine
and using [git-auto-commit-action](https://github.com/stefanzweifel/git-auto-commit-action) to then commit and push the
client changes to the PR branch automatically, which means that developers do not need to build and run the tools
manually.

The downside to this approach is that PRs could get rather large and span multiple folders, potentially increasing build
times as well as making it more likely a merge conflict occurs and extending the time of the pull request process.

#### Generate clients on main builds with an automated PR

If the client generation tools are run during CI builds on `main`, PR sizes can be kept small, but there would be a
period of time between when the breaking server change is checked in before the client code is updated. During this
time, older clients running on developer machines may not function properly.

The entire process for generating this PR can be automated; during a CI build the client generation scripts would be
run, and if there are any changes in the repo, the
[create-pull-request](https://github.com/peter-evans/create-pull-request) action can be used to create a branch and
commit the changes to that branch, automatically opening a PR and assigning it to the original committer. If the build
for this PR is built successfully, the PR can be automatically merged without any sign-offs; however if the build fails,
the original committer would need to work in that branch to fix the client code.

This advantage of this method is our PRs are distinctly separated as much as possible and easier to review. Separated
PRs could also be divided between members of the team to possibly work in parallel. The downside is that that period
where the libraries are out of sync could potentially cause confusion.

#### Decision

Both approaches of when to generate the code would work fine, there is likely not a right answer currently. In order to
reflect our microservice architecture, it could be slightly preferred to generate the clients on main builds, but if
this proves to be problematic, switching to generating clients on PR builds would not be difficult, and either way there
would be no architectural changes, just changes in our CI pipelines.

## Recommendations

The purpose of NSwag is to simplify the overall toolchain to use a single tool with a single configuration file as
opposed to using Swashbuckle + AutoRest. In that respect it does a good job of being feature-filled and easy to use.
When it comes to generating the OpenAPI file, either NSwag or Swashbuckle would be more than adequate. The decision to
go with AutoRest vs NSwag should come down to whether or not Azure Identity providers will be used - if so AutoRest
takes care of that automatically and should be used; otherwise NSwag could be used so that a single tool is used
throughout our builds.

Regardless of the tool that generates the clients, it is recommended for this project that the clients are placed in
their own NPM package, with updates happening automatically on CI builds in main that detect changes.
