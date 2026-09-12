# AGENTS.md

## Project

Finger Chooser (formerly Fingerlette) is a Flutter app for a multi-touch party
game that randomly picks a winner from up to 5 players.

The Dart package name `finger_roulette` and the bundle id
`com.furkanozarar.fingerroulette` predate the rename. Keep them: App Store
Connect ties the listing, ratings and TestFlight builds to the bundle id.
The name users see must stay consistent across three places — the App Store
name, `CFBundleDisplayName` in `ios/Runner/Info.plist`, and `android:label` —
or review rejects under Guideline 2.3.8.

## Common Commands

- `flutter pub get`
- `flutter gen-l10n` — regenerate localization code after editing ARB files
- `flutter analyze`
- `flutter test`
- `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshots_test.dart -d "iPhone 14"`
  — plays every mode with synthetic fingers and writes screenshots to
  `build/screenshots/` (`SCREENSHOT_DIR=...` to change the folder,
  `--dart-define=SCREENSHOT_LOCALE=tr` for another language). A simulator only
  delivers two real touches, so this is the only way to see 3+ player screens;
  App Store screenshots come from here too.

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
- `GameMode` (pick / teams / order) decides what a round reveals; in pick mode
  `PickOutcome` only reframes the very same draw as winners or losers, which is
  why they share one mode tile. Every mode shares the finger mechanic, so the
  controller fills exactly one of `pickedPointerIds`, `teamOfPointer` or
  `rankedPointerIds` and exposes `spotlightPointerIds` for the UI.
- `FingerPainter` knows nothing about modes: it draws whatever is in
  `spotlightPointerIds` and `labels`. Its glows are radial gradients, not
  `MaskFilter.blur` — five blurred circles at once (team mode) dropped frames.
- The roulette beam that spins before the reveal is `SpinBeam`, pure geometry
  recomputed once per frame in `HomeScreen` and handed to both the painter and
  the tick sound. Because it has to land on the actual result, the draw happens
  when the fingers lock (`_drawResult`), not at reveal time; the result waits in
  private fields so the UI can't reveal it early. The beam spins at a constant
  speed for the first 75% of `GameController.spinDuration` and decelerates over
  the rest — an easeOut across the whole spin made the first frames a blur and
  the tick sounds a machine gun.
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
