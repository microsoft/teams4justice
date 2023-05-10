# Forms

Forms are inherently difficult. Individual inputs are easy to manage (such as a
singular search input), but building out multi-input forms results in a very
complex set of user interface states. While the
[@fluentui/react-northstar](https://aka.ms/fluent-ui) library provides okay
individual input elements, the library lacks complete form management tools.

When developing a complete user experience, forms must provide a set of
interactive states. All forms should start in an _initial_ state that renders
default or placeholder values. When a user begins modifying an input, that input
should become _touched_, meaning that the form can start validating the user
input and rendering things such as errors or hints. If an input is invalid, it
should be in some form of an _error_ state, generally indicated by a red color
and an associated message. When all inputs are valid, the form can be submitted
and then considered a _loading_ or _submitting_ state. If something goes wrong,
the form can enter the _error_ state and either indicate globally what is wrong
or pass the issue down to a specific input.

Fluent UI Northstar is not capable of delivering the necessary user experience
on its own. To create a quality user experience, combine FluentUI Northstar with
one of the many popular React form libraries.

Currently, the [react-hook-form](https://react-hook-form.com/) library is highly
recommended by the community. It provides a set of easy-to-use hooks to control
all different kinds of form inputs into a great form experience. It is
compatible with TypeScript, and there is an
[@fluentui/react-northstar-prototypes
FormValidation](https://github.com/microsoft/fluentui/blob/dab45a2afe609709735b9b6e604a1af40d50e809/packages/fluentui/react-northstar-prototypes/src/prototypes/FormValidation/FormHooks.tsx)
example to get you started.

Another option is to use the equally popular [Formik](https://formik.org/)
library. Similarly, it supports TypeScript and has an
[example](https://github.com/microsoft/fluentui/blob/dab45a2afe609709735b9b6e604a1af40d50e809/packages/fluentui/react-northstar-prototypes/src/prototypes/FormValidation/Formik.tsx)
to get you started.

The developer experience for each library is based on preference.
**react-hook-form** makes heavy use of the react-hooks api. Forms and inputs are
connected via hooks and prop controls. **Formik** is more component based API
where you wrap the **Northstar** components in another component and then use
that to create a form.
