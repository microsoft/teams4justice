# Calendar

As recommended by the [calendar component trade
study](../../trade-studies/calendar-component.md), this projects makes use of
the third-party [React Big
Calendar](https://github.com/jquense/react-big-calendar) module. The library is
stable enough and well supported to be considered a safe long-term option.

The GitHub has a number of open PRs and Issues, but it seems as though the
maintainers do a good job of managing the ones that matter.

There are not many alternatives, and aside from swapping Moment with Luxon, the
calendar implementation in the app should be considered stable.

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
