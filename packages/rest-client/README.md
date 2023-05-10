# REST client

> see https://aka.ms/autorest

This package contains AutoRest-generated client code. It will be updated automatically by the
rest-client.yml GitHub Actions workflow using the create-pull-request GitHub Action to automatically
create a PR when the input OpenAPI JSON file is modified in main.

More details can be found in the [trade study] for this topic.

## Getting started

There is a package.json with dependencies that could be installed, but are not actually doing anything right now.
We are skipping linting for auto-generated files.

Right now we're doing our work in rest-client.yml.

## Configuration

This configuration below is run by the pipeline (or from your command line), using a literate configuration. The
`'see https://aka.ms/autorest'` at the top of this page flags it as a config file. **NOTE**: changes to the yaml below
will actually change the output to the REST client!

To run from the command line first install:

> (sudo) npm install -g autorest@3.2.1

Then run autorest pointing to this file:

> autorest src/rest-client/README.md

Docs on how to create and update this can be found in the [Autorest Github repo](https://github.com/Azure/autorest/blob/main/docs/generate/readme.md#keeping-your-options-in-one-place-the-preferred-option).

```yaml
input-file: ../api/swagger.json
output-folder: ./lib
typescript: true
generate-metadata: false
clear-output-folder: true
```
