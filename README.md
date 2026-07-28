# JATaskManager — Client Project Tracker

A SwiftUI app for tracking client projects (client, project, status, priority, dates), built with Clean Architecture + MVVMC.

## Setup

### Tech stack

- Swift 6 (strict concurrency), SwiftUI, iOS 17+, no third-party dependencies.
- Clean Architecture / MVVMC, layered under `JATaskManager/`:
  - `Domain/` — entities, `ProjectRepository` protocol, use cases, `ProjectValidator`, `ProjectListFiltering`.
  - `Data/` — `JSONLoader`, `ProjectDTO`/`ProjectMapper`, `FileProjectStore`, `MockProjectRepository` (actor + file persistence).
  - `Presentation/` — view models, views, `ProjectNotificationService`, appearance toggle.
  - `App/` — `AppCoordinator` (composition root) and `ProjectCoordinator` (navigation).

### Run it

1. Open `JATaskManager.xcodeproj` in Xcode 16+.
2. Select the `JATaskManager` scheme and an iOS 17+ simulator (prefer a simulator matching the project’s deployment OS).
3. `Cmd+R`.

Or from the command line:

```bash
xcodebuild build -project JATaskManager.xcodeproj -scheme JATaskManager -destination 'generic/platform=iOS Simulator'
```

The app opens on the project list (12 seeded projects on first launch). Tap a row for details, Edit/Delete from there, or use `+` to create a project. Pull to refresh. Search the list, filter by status/priority, and toggle Appearance from the toolbar.

### Features

- **CRUD** with form validation, list loading/error/retry, and save/delete ProgressView overlays.
- **Persistence / offline** — projects are saved to Application Support (`JATaskManager/projects.json`). First launch seeds from `Resources/test_data.json`; later launches load the file. All CRUD works without a network.
- **Search & filter** — searchable client/project name; status and priority menus; empty-filter state when nothing matches.
- **Appearance** — System / Light / Dark via `@AppStorage` + `.preferredColorScheme`.
- **Push simulation** — local notifications: due-soon schedule after save (within 3 days), plus a Demo Notification action on detail.
- **Navigation** — Create and Edit sheets are owned by `ProjectCoordinator`; detail updates in place after edit.

### Assumptions

- `Project.id` is `Int`, matching the JSON; new ids are `(current max) + 1`.
- Date strings on disk use ISO8601 full-date (`yyyy-MM-dd`), same as the bundled seed.
- Unit tests cover `ProjectListFiltering` and `FileProjectStore` (temp directory). Broader use-case tests can still be added later.
- Deleting the app (or wiping the container) resets to a fresh seed on next launch.

## Q&A

**Why this implementation approach?**
The assessment asked for something built "the way a mature codebase would be," so Clean Architecture with protocol-based DI at every layer boundary made sense. The data layer can be swapped for a real backend without touching Domain or Presentation, and validation lives once (`ProjectValidator`).

**1. Tradeoffs**
- More files/indirection than a single-screen prototype needs.
- Local JSON persistence is enough for offline demo; it is not a sync engine.
- Push demo uses local notifications only (no APNs).

**2. What I'd improve with more time**
- Unit tests for use cases and the repository across a fresh repository instance sharing the same store path.
- Sorting options on the list.
- Accessibility pass (VoiceOver, Dynamic Type).

**3. Most challenging part**
Balancing architecture weight against assessment scope, and wiring persistence + coordinator edit without stale detail state.

**4. AI tools used?**
Yes, as a coding assistant during implementation — all architectural decisions and code review were mine. Claude, ChatGPT
