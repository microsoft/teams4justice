# Rendering Calendar Component

Calendar component is used to render meeting events for court rooms within a Teams Channel.

Since React-northstar, React and Teams SDK do not have a component to render calendar by default, we need to use a third
party library react big calendar. Refer to [calendar component trade study](../../trade-studies/calendar-component.md) for
more details on the workarounds & solution choice.

## Prerequisites

To install the calendar component and library you will need:

- A Package Manager (NPM or Yarn)

Node Package Manager(npm) comes pre-installed with Nodejs, follow the instructions [here if you don't already have
nodejs installed](https://nodejs.org/en/download/). You can use [yarn](https://classic.yarnpkg.com/en/docs/install/) as
well.

### Install React Big Calendar Package

1. Open the [React-big-calendar npm package page](https://www.npmjs.com/package/react-big-calendar) and copy the command
   to install the module. Install either via yarn or npm.
2. To install the module, start a cmd session, and then Paste the command you have copied.

```cmd
npm install --save react-big-calendar
```

or

```cmd
yarn add react-big-calendar
```

### Using the module

```typescript
import { Calendar, momentLocalizer } from "react-big-calendar";
import "react-big-calendar/lib/css/react-big-calendar.css";
import moment from "moment";
```

> Note: We need the react-big-calendar.css for styling.

The calendar element needs a localizer. Declare as such at your render section. If you plan to use a different datetime
library other than moment, refer the [Localization documentation](https://www.npmjs.com/package/react-big-calendar) on
how to set up respective localizers.

```typescript
const localizer = momentLocalizer(moment);
```

The calendar element can be use as follow:-

```css
<div>
    <Calendar
        localizer={localizer}
        events={[{  title: 'test',
                    start: new Date(2020, 12, 9, 12),
                    end: new Date(2020, 12, 9, 13),
                    allDay: 'false',}]}
        startAccessor="start"
        endAccessor="end"
        views={['month', 'day', 'agenda']}
        style={{ height: 600, marginLeft: '2em' }}
    />
</div>
```

> Notes:
>
> 1. Calendar's container element needs to have a height or the calendar won't be visible.
> 1. Height 600 renders the element in Teams desktop just nice.
