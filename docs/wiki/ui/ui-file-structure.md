# UI file structure

The UI began development without a regimented file structure, and later, with the amount of people developing the UI, a
massive restructuring would be disruptive. Instead we should slowly converted the file structure to match [the structure
outlined below](#Planned-file-structure).

## React best practices

The React documentation outlines [file structure best practices](https://reactjs.org/docs/faq-structure.html). It's
common to organise folders either by feature (e.g. Hearing-related files are in the same folder) or by file type (e.g.
API-related files are in the same folder).

We will organise React code in `ui/src/components/` by feature.

## Planned file structure

Component folders contain the files needed for one component, or more components if they are closely related (e.g.
`HearingDetails` and `ExistingHearingDetails`). They can exist at the `ui/src/components/` level as well.

As we are developing, we should moves files into their respective folder to match the below structure:

```txt
├── components/
│   ├── api/
│   │
│   ├── auth/
│   │
│   ├── courtroom/
│   │   ├── CourtroomCalendar/  // TODO: Rename from HearingCalendar.
│   │   ├── CourtroomContext/
│   │   ├── CourtroomNavbar/    // TODO: Rename from Navbar for T4J.
│   │   └── CourtroomPage/
│   │
│   ├── hearing
│   │   ├── cards/
│   │   │   └── // TODO: Move all hearing card files here.
│   │   │
│   │   ├── dialogs/
│   │   │   └── // TODO: Move all hearing card dialog files here.
│   │   │
│   │   ├── HearingControl/
│   │   ├── HearingDetails/
│   │   ├── HearingNavbar/      // TODO: Create component for T4J.
│   │   ├── HearingPrivateRooms/
│   │   ├── HearingSidebar/
│   │   └── HearingRoutes.tsx
│   │
│   ├── NavbarWrapper/          // TODO: Create component for T4J. Will be used by CourtroomNavbar and HearingNavbar.
│   │
│   ├── search/
│   │   ├── cards/
│   │   │   └── // TODO: Move all search card files here.
│   │   │
│   │   ├── CourtSearch/        // TODO: Rename from HearingSearch.
│   │   └── SearchNavbar/       // TODO: Create component from existing code.
│   │
│   ├── setup/
│   │
│   ├── TimeZoneDropdown/
│   │
│   ├── App.tsx
│   ├── ianaTimeZoneOptions.ts
│   ├── LoadingSpinner.tsx
│   ├── Privacy.tsx
│   ├── PrivateRoute.tsx
│   └── TermsOfUse.tsx
```

Tests, CSS, indexes, and other closely related files will live in the same folder as the components that reference them.
Multiple components can share the same component folder:

```txt
├── components
│   ├── hearing
│   │   ├── HearingNavbar
│   │   │   ├── HearingNavbar.css
│   │   │   ├── HearingNavbar.test.tsx
│   │   │   ├── HearingNavbar.tsx
│   │   │   ├── index.ts
│   │   │   └── someExampleUtils.ts
│   │   │
│   │   └── index.ts
```

We will not nest folders deeper than this since that makes it hard to manage relative imports.
