# AGENTS.md

## Project

Fingerlette (Finger Roulette) is a Flutter app for a multi-touch party game
that randomly picks a winner from up to 5 players.

## Common Commands

- `flutter pub get`
- `flutter gen-l10n` — regenerate localization code after editing ARB files
- `flutter analyze`
- `flutter test`

## Project Notes

- Main app code lives in `lib/`.
- Sound assets are listed in `pubspec.yaml` under `assets/sounds/`.
- App icon and splash configuration are managed from `pubspec.yaml`.
- Keep changes small and focused.
- Do not edit generated build output unless explicitly needed.
- Preserve platform folders (`android/`, `ios/`, `web/`, `macos/`, `linux/`,
  `windows/`) unless the task is platform-specific.

## Architecture

- `GameController` holds all game logic and state; it is pure Dart and knows
  nothing about `BuildContext`. Animation controllers live in `HomeScreen`
  because they need a `TickerProvider`.
- Services (`SoundService`, `StatsService`, `ReviewService`) are injected into
  `GameController` so tests can substitute fakes. `StatsService` and
  `ReviewService` are created and initialised in `main()` before `runApp`.
- User-facing strings are never built in the controller — `lib/screens/game_text.dart`
  maps game state to localized text at the UI layer.

## Localization

- Source of truth is `lib/l10n/app_*.arb`; `app_en.arb` is the template and the
  only file that declares placeholders.
- 16 locales are supported: en, ar, de, es, fr, hi, id, ja, ko, ms, pt, ru, th,
  tr, vi, zh.
- Adding a string: add it to `app_en.arb` with a `@description`, add the
  translation to every other ARB file, then run `flutter gen-l10n`.
- Adding a locale: create `app_<code>.arb`, and add the code to
  `CFBundleLocalizations` in `ios/Runner/Info.plist` — without that entry iOS
  reports only the development language and the translation never shows.
- `test/localization_test.dart` fails if any locale is missing a key or leaves
  an unresolved ICU placeholder.

## Before Finishing

- Run `flutter analyze` after Dart or Flutter changes when practical.
- Run `flutter test` — the suite covers game flow, review-prompt gating, and
  localization completeness.
