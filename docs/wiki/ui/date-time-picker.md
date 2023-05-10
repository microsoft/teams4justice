# Date Time Picker

In the create hearing form, there is a complex input called a _Date Time
Picker_. FluentUI Northstar provides an incomplete component, but the
recommended solution is to use the HTML native [`<input type="datetime-local"/>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/datetime-local).
This element provides a browser agnostic, accessible user experience, and can be
used with _any_ additional form library or styling framework. Any other
React-based implementation will suffer from interopability and accessibility
issues.

As discussed in the [forms](./forms.md) document, the recommended form
management libraries will work with `datetime-local` and can be used to create a
quality user experience in the applications form components.

Outstanding issues related to the datetime picker UI are:

- Note: as detailed in this document, using a third-party library for this component may not be the best option.
