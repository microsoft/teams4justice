# Validation

Our general approach to validation is discussed in the [validation trade study](../trade-studies/validation.md).

Other resources include:

- [Nest Validation docs](https://docs.nestjs.com/techniques/validation)
- [class-validator library docs](https://github.com/typestack/class-validator)

This document will describe some specific features of implementing decorator-based validation as well as options for
customization.

## Custom validation pipe

If the built-in ValidationPipe does not meet our needs, we can build a custom validation pipe. We saw one example of a
custom validation that implements schema-based validation in our validation trade study. Below is an example of a custom
validation pipe that implements decorator-based validation.

```typescript
import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
} from "@nestjs/common";
import { validate } from "class-validator";
import { plainToClass } from "class-transformer";

@Injectable()
export class ValidationPipe implements PipeTransform<any> {
  async transform(value: any, { metatype }: ArgumentMetadata) {
    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }
    const object = plainToClass(metatype, value);
    const errors = await validate(object);
    if (errors.length > 0) {
      throw new BadRequestException("Validation failed");
    }
    return value;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }
}
```

## Validation messages

You can specify validation messages in the decorator options and that message will be returned in the ValidationError
returned by the validate method (in the case that validation for this field fails).

```typescript
import { MinLength, MaxLength } from "class-validator";

export class Post {
  @MinLength(10, {
    message: "Title is too short",
  })
  @MaxLength(50, {
    message: "Title is too long",
  })
  title: string;
}
```

There are few special tokens you can use in your messages:

- `$value` - the value that is being validated
- `$property` - name of the object's property being validated
- `$target` - name of the object's class being validated
- `$constraint1`, `$constraint2`, ... `$constraintN` - constraints defined by specific validation type

Example of usage:

```typescript
import { MinLength, MaxLength } from "class-validator";

export class Post {
  @MinLength(10, {
    // here, $constraint1 will be replaced with "10", and $value with actual supplied value
    message:
      "Title is too short. Minimal length is $constraint1 characters, but actual is $value",
  })
  @MaxLength(50, {
    // here, $constraint1 will be replaced with "50", and $value with actual supplied value
    message:
      "Title is too long. Maximal length is $constraint1 characters, but actual is $value",
  })
  title: string;
}
```

Read more on validation messages on the [class-validator GitHub
page](https://github.com/typestack/class-validator#validation-messages).

## Mapped types

As you build out features like CRUD (Create/Read/Update/Delete) it's often useful to construct variants on a base entity
type. Nest provides several utility functions that perform type transformations to make this task more convenient.

> WARNING: Since our application uses the `@nestjs/swagger` package, it relies heavily on types and so we require the
> swagger-specific import to to be used. If you use `@nestjs/mapped-types` (instead of `@nestjs/swagger`), you may face
> various, undocumented side-effects.

The `PartialType()` function returns a type (class) with all the properties of the input type set to optional.

```typescript
export class UpdateUserDto extends PartialType(CreateUserDto) {}
```

The `PickType()` function constructs a new type (class) by picking a set of properties from an input type.

```typescript
export class UpdateUserAgeDto extends PickType(CreateUserDto, [
  "age",
] as const) {}
```

The opposite of `PickType()`, the `OmitType()` function constructs a type by picking all properties from an input type
and then removing a particular set of keys.

```typescript
export class UpdateUserDto extends OmitType(CreateUserDto, ["name"] as const) {}
```

The `IntersectionType()` function combines two types into one new type (class).

```typescript
export class UpdateUserDto extends IntersectionType(
  CreateUserDto,
  AdditionalUserInfo
) {}
```

The type mapping utility functions are composable. For example, the following will produce a type (class) that has all
of the properties of the CreateUserDto type except for name, and those properties will be set to optional:

```typescript
export class UpdateUserDto extends PartialType(
  OmitType(CreateUserDto, ["name"] as const)
) {}
```
