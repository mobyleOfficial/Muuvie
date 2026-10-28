# Moovie

A modular Flutter app for movie marathons: shelves, watch logs, maratonas, CineClubes and a social feed. Built by Mobyle using Clean Architecture, BLoC state management, and a multi-package monorepo structure.

---

## Overview

Moovie is a multi-flavor Flutter application that consumes The Movie Database (TMDB) API and a custom backend. It supports English, Spanish, and Portuguese, adapts to light/dark themes, and is structured as a monorepo with independently versioned packages for each feature and UI module.

**Main tabs:**
- **Atts** — Social feed
- **Programação** — Maratonas and CineClubes
- **Catálogo** — Discovery and search
- **Notícias** — News
- **Perfil** — User profile

---

## Installation

### Prerequisites

- Flutter SDK (Dart `^3.11.4`)
- Ruby 3.2.0 (via rbenv or system)
- Android Studio or VS Code with Flutter extension
- Environment file at `secrets/.env` (see [Configuration](#configuration))

### Steps

```bash
# 1. Clone the repository
git clone <repo-url>
cd moovie

# 2. Setup environment
rbenv local 3.2.0
bundle install

# 3. Setup environment variables interactively
bundle exec fastlane setup_env
# (Or copy manually: cp secrets/.env.example secrets/.env)

# 4. Install Flutter dependencies (root + all packages)
flutter pub get

# 5. Run code generation (routing, DI, ObjectBox)
dart run build_runner build --delete-conflicting-outputs

# 6. Setup IDE run configurations
bundle exec fastlane setup_ide

# 7. Run the app
flutter run                              # production flavor
flutter run -t lib/main_dev.dart        # dev flavor
flutter run -t lib/main_staging.dart    # staging flavor
```

---

## Configuration

The app reads environment variables at build time. Create a `.env` file in the `secrets/` folder:

```bash
cp secrets/.env.example secrets/.env
```

Then edit `secrets/.env`:

```env
TMDB_API_KEY=your_tmdb_bearer_token
DEV_BACKEND_URL=http://localhost:8080
STG_BACKEND_URL=https://api-staging.example.com
PROD_BACKEND_URL=https://api.example.com
```

| Variable | Description |
|----------|-------------|
| `TMDB_API_KEY` | Bearer token for the TMDB v4 API |
| `DEV_BACKEND_URL` | Base URL for the Moovie backend service (dev flavor) |
| `STG_BACKEND_URL` | Base URL for the Moovie backend service (staging flavor) |
| `PROD_BACKEND_URL` | Base URL for the Moovie backend service (prod flavor) |

### App Flavors

| Flavor | Entry point | App name | Launcher icon & splash |
|--------|-------------|----------|------------------------|
| `prod` | `lib/main.dart` | Moovie | White cow on black |
| `staging` | `lib/main_staging.dart` | Moovie[Stg] | White cow on pink |
| `dev` | `lib/main_dev.dart` | Moovie[Dev] | Black cow on white |

Flavor-specific configuration lives in `lib/config/app_config.dart`.

Launcher icons are generated per flavor from `assets/launcher/` using the `flutter_launcher_icons-<flavor>.yaml` configs. After changing a source image, run `dart run flutter_launcher_icons`. The tool rewrites the wrong iOS build setting, so restore `ios/Runner.xcodeproj/project.pbxproj` afterwards. Each build configuration already points `ASSETCATALOG_COMPILER_APPICON_NAME` at its `AppIcon-<flavor>` set.

Splash screens are also per flavor, including Android 12+. They are generated from `assets/launcher/splash_<flavor>*.png` with the `flutter_native_splash-<flavor>.yaml` configs. To regenerate, run `dart run flutter_native_splash:create --flavors dev,staging,prod`. The tool reformats `ios/Runner/Info.plist` and points it back to a single storyboard, so restore that file afterwards. On iOS, `UILaunchStoryboardName` reads `$(LAUNCH_SCREEN_STORYBOARD)`. That build setting is set per configuration to `LaunchScreen<Flavor>`, and the three storyboards are registered in the Runner target.

### Empty-state illustrations

`MuuvieEmptyState` shows a mascot illustration (`MuuvieIllustration`) above its copy. Pass `illustration: null` in tight spaces such as bottom sheets. The SVGs live in `ui/common/assets/illustrations/` and use fixed design-system colors as roles: `primary` for ink, `neutral` for paper and `onSecondaryContainer` for details drawn over pink. Lines drawn straight on the page (tail, hooves, "zzz", handles) use `#1A1C1F`, the same black as a separate role. `MuuvieIllustrationView` swaps those role colors at runtime: in light mode they follow the theme, and in dark mode the cow stays white with black spots, like the app icon, while only the lines on the page turn light. The same file works in both modes.

### Vaquinhas

Each vaquinha of the Vaquinha da Bombonière is the cow in a costume. Their round avatars live in `ui/gamification/assets/pets/<slug>.svg`, named by the slug the backend sends. `PetAvatar` draws them with `MuuvieMascotArt` in their original colors on the pastel circle of their rarity, in both themes. An unknown slug falls back to `pipoca-doce`.

---

## Project Structure

```
moovie/
├── lib/                        # Main app (entry points, routing, DI)
│   ├── main.dart               # Production entry point
│   ├── main_dev.dart
│   ├── main_staging.dart
│   ├── config/
│   │   └── app_config.dart     # Flavor configuration
│   ├── di/
│   │   ├── injection.dart      # GetIt setup
│   │   ├── http_di_module.dart # Dio clients (TMDB + Backend)
│   │   └── movies_module.dart  # Movies use case bindings
│   └── routes/
│       ├── app_router.dart     # Route definitions (auto_route)
│       ├── main_navigation.dart # The five tabs and their rules (login, initial tab)
│       └── main_screen.dart    # Bottom navigation shell
│
├── core/                       # Shared abstractions package
│   └── lib/                    # HttpClient interface, UseCase base, Result types
│
├── features/                   # Business logic (Clean Architecture)
│   ├── movies/
│   │   ├── domain/             # Package: movies_domain (pure Dart, no deps)
│   │   │   └── lib/            # Entities, repository contracts, use cases
│   │   └── data/               # Package: movies_data (implements domain)
│   │       └── lib/            # Data models, repositories, datasources
│   ├── news/                   # News on /api/v1: source filter, quoted movies, "read" marks kept on the device
│   │   ├── domain/             # Package: news_domain
│   │   └── data/               # Package: news_data
│   ├── shelves/                # Shelves on /api/v1 (Já assisti, Quero ver and the user's own), locadoras (groups of shelves) and their discovery
│   ├── watch_logs/             # Watch sessions, star rating, favorite, situations and comments on /api/v1
│   ├── imports/                # Filmow import jobs on /api/v1: preview, progress (WebSocket), match queue
│   ├── social_network/         # Feed (Atts), "amei", follows with the mutual state and Sussurros on /api/v1; new messages and the unread badge arrive on the WebSocket. Also the progress feed of a maratona
│   ├── maratonas/              # Maratonas on /api/v1: list and filters, detail, join/leave, challenges and their links, suggestions per challenge, ranking, editor form and templates
│   ├── cineclubes/             # CineClubes on /api/v1: list and filters, detail with sessions and watch providers, join/leave, progress (spoiler gate from the server), participants, editor form
│   ├── stats/                  # Charts of a year, calendar, retrospective and yearly goals on /api/v1
│   ├── gamification/           # Vaquinha shelter, weekly missions, Caderninho, watch parties (rooms refreshed by the watch_party WebSocket event) and the poster game on /api/v1
│   ├── onboarding/             # Whether the introduction of the new concept was seen, kept on the device
│   └── profile/                # Profile on /api/v1: @handle, counters, highlights, discovery of profiles
│       ├── domain/             # Package: profile_domain
│       └── data/               # Package: profile_data
│
└── ui/                         # Presentation layer (UI packages)
    ├── common/                 # Shared: theme, components, localization
    ├── movies_ui/              # Movie detail (rating, Na Programação, Registros tab, trailer) and person page
    ├── search/                 # Catálogo: discovery hub (releases, community shelves and locadoras, profiles) and search
    ├── social/                 # Atts tab: the feed with Todos · Seguindo · Só eu, "amei" and hiding my own activities
    ├── whispers/               # Sussurros: conversations with mutuals, in real time; the unread badge sits in the Atts app bar
    ├── profile/                # Profile view shared by my profile and others' (header, Destaques · Estantes · Registros · Locadoras · Participações · Gráficos tabs), retrospective stories shared as an image, yearly goal, settings (import, push preferences, introduction again, logout), edit profile, highlights editor, shelf detail, followers and following lists (package: profile_ui)
    ├── public_profile/         # Someone else's profile; route opened by id or @handle
    ├── shelves/                # "Add to shelves" modal used by movie detail (package: shelves_ui)
    ├── locadoras/              # Locadoras tab (own and public profile), detail with corridors, shelf picker (package: locadoras_ui)
    ├── watch_logs/             # Session form, rating, history, GIF picker, comments, movie panel, "watching now" (package: watch_logs_ui)
    ├── imports/                # Import flow: Filmow login, preview, progress, report, match queue (package: imports_ui)
    ├── programacao/            # Programação tab: Maratonas | CineClubes, each with search, filters, "Participando" and create
    ├── maratonas/              # Maratona detail (Sobre · Desafios · Minha Fila · Descoberta · Ranking), join sheet, marking a challenge with a movie, editor with criteria builder and templates (package: maratonas_ui)
    ├── cineclubes/             # CineClube detail (Sobre · Progresso · Participantes, the movies of a cycle), editor with movie search and sessions (package: cineclubes_ui)
    ├── gamification/           # Vaquinha da Bombonière, missions, Caderninho, watch party and poster game screens, the vaquinha row of the profile (package: gamification_ui)
    ├── onboarding/             # Introduction shown once per install: panels, Filmow import, open maratonas and CineClubes (package: onboarding_ui)
    └── news/                   # Notícias tab (featured article, source filter, read marks) + article detail with quoted movies (package: news_ui)
```

### Package dependency graph

```
App (moovie)
 ├── core
 ├── features/<name>  ──>  <name>_data  ──>  <name>_domain  ──>  core
 └── ui/<module>      ──>  common
                      ──>  features/<name>  (via domain layer only)
```

- `domain` packages have **zero** external dependencies — pure Dart.
- `data` packages implement `domain` contracts and own all serialization/persistence.
- UI modules never import from another feature's `data` layer.

---

## Architecture

### State Management

BLoC / Cubit (`flutter_bloc`). Each UI module has three files:

| File | Role |
|------|------|
| `<module>_state.dart` | Sealed state classes: `Loading`, `Success`, `Error` |
| `<module>_bloc.dart` | Cubit starting in `Loading`, emitting states |
| `<module>_screen.dart` | `@RoutePage()` widget with `BlocBuilder` |

### Dependency Injection

GetIt + Injectable. Modules are annotated with `@module` and registered in `lib/di/`. Two named `Dio` clients are provided:

- `@Named('tmdb')` — TMDB API with Bearer token header
- `@Named('backend')` — Custom backend client

After any DI annotation changes, regenerate with:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Routing

Auto Route with nested tab navigation:

The tabs live in `lib/routes/main_navigation.dart`: Atts (SocialTab) · Programação · Catálogo (SearchTab) · Notícias · Perfil. Programação and Notícias work logged out; logged in, the app opens on Atts.

```
MainRoute
├── SocialTab       → SocialRoute (Atts)
├── ProgramacaoTab  → ProgramacaoRoute
├── SearchTab       → SearchRoute (Catálogo)
├── NoticiasTab     → NewsListRoute
└── ProfileTab      → ProfileRoute

(push) MovieDetailRoute, MaratonaDetailRoute, CineClubeDetailRoute, ... inside each tab
```

Maratona links: `/m/<slug>` (e.g. `muuvie://muuvie.app/m/terror-70`) open `MaratonaDetailRoute` over the main screen the same way, and CineClube links `/c/<slug>` open `CineClubeDetailRoute`.

Profile links: `https://muuvie.app/@handle` (and `muuvie://muuvie.app/@handle`, which works before the domain is verified) open `PublicProfileRoute` over the main screen (`profileDeepLink` in `lib/routes/app_router.dart`). Test on Android with `adb shell am start -a android.intent.action.VIEW -d "muuvie://muuvie.app/@handle"`.

After any route annotation changes, regenerate with `build_runner`.

### Local Storage

ObjectBox for on-device persistence. Entities with `@Entity()` annotations require code generation:
```bash
dart run build_runner build
```

---

## Localization

Strings are defined in ARB files under `ui/common/lib/l10n/` and accessed via `AppLocalizations`.

Supported languages: **English** (`en`), **Spanish** (`es`), **Portuguese** (`pt`)

### Adding a string

1. Add to `app_en.arb`:
   ```json
   "myKey": "My string",
   "@myKey": { "description": "What this string is for" }
   ```
2. Add translated values to `app_es.arb` and `app_pt.arb`.
3. Regenerate:
   ```bash
   flutter gen-l10n
   ```
4. Use in any widget:
   ```dart
   AppLocalizations.of(context)!.myKey
   ```

Never hardcode user-visible strings in widgets. Always import `AppLocalizations` through `package:common/common.dart`.

---

## UI Components

Shared components live in `ui/common/` and are exported from `package:common/common.dart`:

| Component | File |
|-----------|------|
| `MoovieScaffold` | `moovie_scaffold.dart` |
| `MoovieAppBar` | `moovie_app_bar.dart` |
| `MoovieButton` | `moovie_button.dart` |
| `MoovieTextField` | `moovie_text_field.dart` |
| `MoovieDialog` | `moovie_dialog.dart` |
| `MoovieTabBar` | `moovie_tab_bar.dart` |
| `MoovieSwitch` | `moovie_switch.dart` |
| `MoovieSlider` | `moovie_slider.dart` |
| `MoovieIconButton` | `moovie_icon_button.dart` |
| `MoovieActivityIndicator` | `moovie_activity_indicator.dart` |
| `MoovieBottomNavigationBar` | `moovie_bottom_navigation_bar.dart` |

### Theming

Material Design 3 with light and dark variants. Theme configuration is in `ui/common/lib/src/theme/`:

- `moovie_colors.dart` — Color constants
- `moovie_color_scheme.dart` — Color scheme definitions per brightness
- `moovie_text_theme.dart` — Typography scale
- `moovie_theme.dart` — Light/dark `ThemeData` assembly

---

## Development Workflow

### Code generation

Several packages require code generation. Run after any annotation change:

```bash
# All generators (routing, DI, ObjectBox)
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs

# Localization only
flutter gen-l10n
```

### Daily commands

```bash
flutter pub get                                                    # After pubspec changes
dart run build_runner build --delete-conflicting-outputs           # After annotation changes
flutter gen-l10n                                                   # After ARB changes
dart format .                                                      # Format code
bundle exec fastlane lint                                          # Lint
bundle exec fastlane test                                          # Run tests
flutter run -t lib/main_dev.dart                                   # Run dev flavor
```

### Fastlane commands

See [`fastlane/README.md`](fastlane/README.md) for all available fastlane lanes and commands.

All fastlane commands must be run with `bundle exec` to use the locked Ruby gems:

```bash
bundle exec fastlane <lane_name> [options]
```

**Key points:**
- Initial setup: `bundle exec fastlane setup_env` and `bundle exec fastlane setup_ide`
- Dry run is the default for all release lanes (safe by default)
- Explicit `dry_run:false` required to submit to production (with confirmation)

### Adding a new feature

1. Create `features/<name>/` with `domain/` and `data/` sub-packages.
2. Add path dependencies to the root `pubspec.yaml`.
3. Register use cases and repositories in `lib/di/`.
4. Create the UI module under `ui/<name>/` with the three required files (`_state`, `_bloc`, `_screen`).

To scaffold a UI module from the standard template, use the `/new-ui-module <name>` slash command.

---

## Guidelines

### Code style

- Classes: `PascalCase` · Files/directories: `snake_case` · Variables/functions: `camelCase`
- Prefer `const` constructors wherever possible.
- Use `final` for variables that are not reassigned.
- Avoid `dynamic` — always provide explicit types.
- Use arrow syntax (`=>`) for single-expression functions and methods.
- One class per file.

### Accessibility

- All interactive widgets must have a semantic label (`Tooltip`, `Semantics`, or `MergeSemantics`).
- Minimum touch target: **48×48 dp**.
- Text must meet WCAG AA contrast ratios: **4.5:1** for normal text, **3:1** for large text.
- Never rely on color alone to convey state — always pair with an icon, label, or shape change.
- Icon-only buttons must wrap their `Icon` in a `Tooltip` or use `Semantics(label: ...)`.

### Testing

Mirror the `lib/` structure under `test/features/<name>/`:

```
test/features/<name>/
  data/models/        # Serialization tests
  data/repositories/  # Repository implementation tests
  domain/usecases/    # Use case unit tests
  presentation/       # Widget and Bloc/Cubit tests
```

- Every public use case must have at least one unit test.
- Mock all external dependencies — no real network or storage in unit tests.
- Test file naming: `<source_file>_test.dart`.

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` / `bloc` | State management (BLoC/Cubit) |
| `rxdart` | Reactive streams |
| `dio` | HTTP client |
| `objectbox` | Local database |
| `auto_route` | Declarative routing with code generation |
| `get_it` / `injectable` | Dependency injection |
| `intl` | Localization and date formatting |
| `cached_network_image` | Network image caching |
| `infinite_scroll_pagination` | Paginated list views |

---

## License

Apache License 2.0 — see `LICENSE` for details.
