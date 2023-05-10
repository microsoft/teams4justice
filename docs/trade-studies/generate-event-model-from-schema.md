# Trade Study: Generate Event Model From Schema

|                 |                               |
| --------------: | ----------------------------- |
| _Conducted by:_ | Bronwen Zande and Jeremy Kime |
|  _Sprint Name:_ | 1                             |
|         _Date:_ | April 2021                    |
|     _Decision:_ | Manual creation of interfaces |

## Overview

In an effort to reduce code repetition and make breaking changes cause compile
errors as opposed to runtime failures, we wish to have a shared library where
all the Event models are stored. This library will only be a collection of
interfaces and not have any other dependencies so it can be consumed by any
other library.

## Goals

- Support generated documentation
- Easily validated with existing or new tooling (e.g. min/max lengths)
- Easy to consume by users (the final result of this tooling should be a usable
  TypeScript package)
- The required tooling works well and is easily integrated into our existing
  toolchain
- Keep the interfaces package as an interface package and not dirty with
  implementation code

## Open questions

1. How tricky/complicated are the entities involved?
2. What patterns/principals should be followed for creation/reuse of entities,
   versioning etc?

## Solutions

The basic principals of the solution that follow for all are:

- Define the models that will be passed across boundaries in a shared package
  for easy reuse, visibility etc. over having objects defined throughout code.
- A balance between multiple objects that are similar vs one object with mainly
  nullable fields. Suggestion here is to start with defined objects with
  required fields and when we need to look at having fields be not
  needed/nullable this is a good time to discuss the way forward with this
  approach.

### Solution 1 - Manual creation of interface

Manually create the Typescript Interface.

Keeping the interfaces clean and preventing implementation code from creeping in
is the biggest risk to this approach. This can be mitigated with a combination
of pull requests, code reviews and adding a clear definition of what ths package
is for in the readme.

The team can add extensive commenting to TypesSript interfaces. Something like
[TSDoc](https://tsdoc.org/) should be used to help standardise the way the
documents are commented. This would give the team a broader range of options
for documentation generation.

If documentation is needed to be generated from this there are node modules that
could be used to generate this into various output formats like Markdown e.g.
[TypeDoc](https://github.com/TypeStrong/typedoc).

#### Pros

- Faster/simplistic if the number of objects is small (say less than 20 over the
  3 months)
- Faster/simplistic if the amount of churn on an object is small
- Only need 1 representation of the object

#### Cons

- Error prone - easy to misspell, use different names, orders, miss changes in
  larger quantities
- Time consuming - if needs to be done in bulk say 500.
- Finer grained points need to be covered in comments e.g. min/max, lengths etc.
- Creation over generation of interfaces may tempt the team to add
  implementation code here.

### Solution 2 - json-schema-to-typescript

There are a number of existing libraries that will convert JSON to TypeScript.
Looked at the following library
[json-schema-to-typescript](https://github.com/bcherny/json-schema-to-typescript#readme)

License: MIT Weekly downloads: 125,314

Features considered

- primitive types
- descriptions - become comments on the property
- mandatory/required
- nested types
- references - external JSON references in other files are handled as a Type
  and not repeated in the same object.
- structure ie folders - This is maintained in the generation. Care will still
  need to be taken especially if following a Mediator pattern if you choose to
  have say a Person object in 2 folders. These will need to have unique names
  else you will get compile errors.

### Process

Steps to autogenerate would need a scripts to make the process clean.

1. Delete existing files from the output directory to catch the case where a
   JSON definition has been removed.
2. Run the tool across the source directory structure e.g. to convert all
   schemas in the **/schemas/** folder to interfaces in the **/types/** folder:

   _json2ts -i schemas/ -o types/ --no-declareExternallyReferenced_

The **-i** parameter specifies the input, in this case the contents of the
'schemas' directory. The **-o** parameter specifies the output, in this case the
'types' directory. The **'declareExternallyReferenced'** switch is used to
prevent duplicate types from being created when externally referenced schemas
are used.

### Known issues

- Not all JSON Scheam elements are expressible in TypeScript e.g minimum,
  maximum. The site does well to document these.

### Open questions

1. What is the JSON used for? If the JSON is used as a basis to creaet API
   specifications / additional documentation for another source it gives more
   weight to start with JSON.

### Assumptions

- The number of models required will be significant enough to warrant the use of
  generation ie somewhere in the magnitude of 50-100
- We have control of the JSON. It is understood the JSON will be handcrafted and
  not an ouput of another API etc. There are a few issues/nuances in the tool
  when converting that are "fixed" by altering the JSON.

#### Pros

- Allows us to have a 2 consumable representations of an object without having
  to create them both manually.
- Could be faster if the team is more familiar with JSON
- JSON representation is useful for future uses such as APIs for external
  parties/extra documention
- Creation of JSON rather than TypeScript as the starting point will mitigate
  the risk that developers will add implementation code in the interface package

#### Cons

- Tooling / magical code generation. This could mean re-working the JSON to get
  the desired Typescript output. E.g.
  <https://github.com/bcherny/json-schema-to-typescript/issues/334>
- Learning - Learning a tool plus the nuances of JSON vs TypeScript could slow
  you down.
- 2 representations of the same object / double handling.
- If hand-crafting the JSON - the cons around misspelling, churn are also
  relevant to the JSON object.

### Decision

At this stage recommend starting with Solution 1 - Manual creation for the
following reasons:

- As the team is technical - there is not a lot of difference between writing a
  JSON file and a TypeScript file.
- PRs and Code reviews can prevent pollution of the package with implementation
- If in the future we need JSON objects and we want to move to JSON-first
  approach there are tools such as
  [typesript-json-schema](https://github.com/YousefED/typescript-json-schema) to
  create JSON Files and then swtich to generating typescript from there.
