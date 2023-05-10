# Trade Study: REST Validation for the API

|                 |                                           |
| --------------: | ----------------------------------------- |
| _Conducted by:_ | Jack Corrigan                             |
|         _Date:_ | 5/10/2021                                 |
|     _Decision:_ | Decorator-based, global-scoped validation |

## Overview

Validation is needed to inspect and ensure that any incoming request to the API contains valid data. Nest has great
[documentation on validation](https://docs.nestjs.com/techniques/validation) in their framework and also describes the
underlying technology used for validation, [pipes](https://docs.nestjs.com/pipes). Nest provides multiple tools for
validation out-of-the-box. Let's take a look at which validation technique is best for us.

A validation pipe either returns the value unchanged, or throws an exception. Therefore, transforming incoming data is
out of scope for this document.

## Goals

- Determine what type of validation is best.
- Determine what validation scope is best.

## Open questions

- What [parsing options](https://github.com/typestack/class-validator#passing-options) do we want to set on our
  validation pipe?

## Solutions - Validation type

### Validation in the handler method

Validation can be done directly in the route handler method. However, this breaks the single responsibility rule (SRP)
so this approach was not considered.

### Validator class

Another option is to create a validator class. But this requires calling the validator at the beginning of each method
which breaks the do not repeat yourself (DRY) principle. So again, this approach was not considered.

### Schema-based validation

One common approach is to build a validation pipe that makes use of object schemas.
[Joi](https://github.com/sideway/joi) is a popular JavaScript library that allows you to create schemas in a
straightforward way, with a [readable API](https://joi.dev/api/?v=17.4.0).

To build a schema-based validation pipe using joi, start by installing the required packages:

```console
yarn add joi
yarn add --dev @types/joi
```

Next create a joi schema object. Here's a simple example:

```javascript
const schema = Joi.object({
  a: Joi.string(),
});
```

And a more detailed example:

```javascript
const schema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required(),
  password: Joi.string().pattern(/^[a-zA-Z0-9]{3,30}$/),
  repeat_password: Joi.ref("password"),
  access_token: [Joi.string(), Joi.number()],
  birth_year: Joi.number().integer().min(1900).max(2013),
  email: Joi.string().email({
    minDomainSegments: 2,
    tlds: { allow: ["com", "net"] },
  }),
})
  .with("username", "birth_year")
  .xor("password", "access_token")
  .with("password", "repeat_password");
```

Then create a validation pipe that takes a schema as a constructor argument and apply the `schema.validate()` method:

```typescript
import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
} from "@nestjs/common";
import { ObjectSchema } from "joi";

@Injectable()
export class JoiValidationPipe implements PipeTransform {
  constructor(private schema: ObjectSchema) {}

  transform(value: any, metadata: ArgumentMetadata) {
    const { error } = this.schema.validate(value);
    if (error) {
      throw new BadRequestException("Validation failed");
    }
    return value;
  }
}
```

#### Pros

- Validation pipe is re-usable across contexts
- DTO class doesn't have any dependencies on validation framework
- Dedicated joi API that also provides a convenient sandbox environment for testing schemas

#### Cons

- Requires the manual creation of a schema object in addition to DTO, meaning information on the required shape of the
  post body is now spread across multiple classes
- Need to write a custom validation pipe
- Cannot make use of Nest mapped types
- joi API and docs written in JavaScript, requires manual conversion to TypeScript

### Decorator-based validation

Decorator-based validation is extremely powerful, especially when combined with Nest's pipe capabilities since we have
access to the metatype of the processed property.

Nest works well with the [class-validator](https://github.com/typestack/class-validator) library, a powerful library
allows you to use decorator-based validation.

> Notes:
>
> 1. Since TypeScript does not store metadata about generics or interfaces, when you use them in your DTOs,
>    ValidationPipe may not be able to properly validate incoming data. For this reason, consider using concrete classes
>    in your DTOs.
> 1. When importing your DTOs, you can't use a type-only import as that would be erased at runtime, i.e. remember to
>    import { CreateUserDto } instead of import type { CreateUserDto }.

To implement decorator-based validation with the built-in `ValidationPipe`, start by installing the required packages:

```console
yarn add class-validator class-transformer
```

- The class-transformer library is required to use the built-in `ValidationPipe`, however, we are not using it yet as we
  are focusing on validation for now. But you can read more about the library on the [class-transformer GitHub
  page](https://github.com/typestack/class-transformer).

Then, mark up your DTO class with decorators:

```typescript
import { IsEmail, IsNotEmpty } from "class-validator";

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsNotEmpty()
  password: string;
}
```

- See the [class-validator GitHub page](https://github.com/typestack/class-validator#validation-decorators) for the full
  list of validation decorators.

We do not need to build a custom validation pipe to use decorator-based validation as it works with Nest's built-in
`ValidationPipe`. All we have to do is set up the scope of the `ValidationPipe` which we will cover in the next section.

#### Pros

- DTO class remains the single source of truth for our data objects (rather than having to create a separate validation
  class)
- Works with Nest's built-in `ValidationPipe`
- Added capabilities when used with Nest mapped types

#### Cons

- Requires TypeScript, not available if your app is written using vanilla JavaScript
- DTO class has dependency on validation framework

### Comparison

The table below summarizes the differences between the validation type solutions:

| Solution                   | Re-usable across contexts | DTO is single source of truth | DTO has no validation dependencies | Works with built-in ValidationPipe | Works in vanilla JS |
| -------------------------- | ------------------------- | ----------------------------- | ---------------------------------- | ---------------------------------- | ------------------- |
| Schema-based validation    | ✔️                        | ❌                            | ✔️                                 | ❌                                 | ✔️                  |
| Decorator-based validation | ✔️                        | ✔️                            | ❌                                 | ✔️                                 | ❌                  |

## Solutions - Validation pipe scope

Validation pipes can have different scopes. These include parameter-scoped, method-scoped, controller-scoped, or
global-scoped. Here's an example of each:

### Parameter-scoped

```typescript
@Get(':id')
async findOne(@Param('id', ParseIntPipe) id: number) {
  return this.userService.findOne(id);
}
```

### Method-scoped

```typescript
@Post()
@UsePipes(new JoiValidationPipe(createUserSchema))
async create(@Body() createUserDto: CreateUserDto) {
  this.userService.create(createUserDto);
}
```

### Controller-scoped

```typescript
@Controller()
@UsePipes(new ValidationPipe())
export default class UserController {
  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    this.userService.create(createUserDto);
  }
}
```

Parameter, method and controller-scoped pipes can be useful when validation logic only concerns a specified set of
elements/actions.

### Global-scoped

Global-scoped pipes are applied to every controller and route handler across the entire application, making it best
suited for generic pipes like the built-in `ValidationPipe`.

```typescript
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe());
  await app.listen(3000);
}
bootstrap();
```

In terms of dependency injection, global pipes registered from outside of any module (with `useGlobalPipes()` as in the
example above) cannot inject dependencies since the binding has been done outside the context of any module. In order to
solve this issue, you can set up a global pipe directly from any module using the following construction:

```typescript
import { Module } from "@nestjs/common";
import { APP_PIPE } from "@nestjs/core";

@Module({
  providers: [
    {
      provide: APP_PIPE,
      useClass: ValidationPipe,
    },
  ],
})
export class AppModule {}
```

Regardless of the module where this construction is employed, the pipe is, in fact, global. It is recommended to choose
the module where the pipe (ValidationPipe in the example above) is defined.

### Decision

**Decorator-based validation** using the built-in `ValidationPipe` setup within a module to have **global scope**
provides a convenient, out-of-the-box approach to enforce validation rules for all incoming client payloads, where the
specific rules are declared with simple annotations in local class/DTO declarations in each module. This approach is
well equipped to handle all our current validation needs for our system. If we find the need to customize this approach
for more specific validation needs, the frameworks and techniques selected provide the ability to do so. For more
information on implementing validation as well as customization, see our [wiki article on
validation](../wiki/validation.md).
