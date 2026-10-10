# AGENTS.md

## Project

Finger Chooser (formerly Fingerlette) is a Flutter app for a multi-touch party
game that randomly picks a winner from up to 5 players on a phone and up to 10
on an iPad.

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
  App Store screenshots come from here too. On an iPad simulator
  (`-d "iPad Pro 13-inch (M5)"`) the same run adds the `17_`–`19_tablet_*`
  frames with eight and ten fingers.
- Switching between a device build and a simulator build needs `flutter clean`
  in between. They share `build/`, and the leftover device slice of a plugin
  framework (`objective_c`) makes the simulator app die at launch with
  "incompatible platform", which reads like a code failure but is not.
- The screenshot run needs the Mac awake for its whole length (about a minute
  per locale). If the Mac sleeps mid-run the simulator freezes and the test
  dies with "pumpAndSettle timed out", which also reads like a code failure.
  `caffeinate` does not prevent it on battery with the lid closed.
- `cd ios && fastlane screenshots` — replaces the App Store screenshots with
  whatever sits in `ios/fastlane/screenshots/<locale>/`. The PNGs are gitignored;
  regenerate them with the `flutter drive` line above. They come out at the
  simulator's own size (1170×2532 on an iPhone 14), which App Store Connect does
  not accept — scale to 1242×2688 first, same aspect ratio so nothing is cropped:
  `sips -z 2688 1242 *.png`. Needs the API key variables from the Fastfile note.
  The store set is seven of the test's frames, renamed with a two-digit order
  prefix: `0_select`, `1_winners_revealed`, `3_teams_revealed`, `6_wheel_idle`,
  `8_wheel_revealed`, `4_order_revealed`, `14_teams_names_four`.

- Build iOS with `FIREBASE_ANALYTICS_WITHOUT_ADID=1` in the environment
  (`FIREBASE_ANALYTICS_WITHOUT_ADID=1 flutter build ipa`). The Firebase package
  reads it while Xcode resolves packages and then links the Analytics build
  without advertising-ID support; without it the app ships IDFA code that the
  privacy policy says it does not have.
- `ios/Runner/GoogleService-Info.plist` is gitignored (the repo is public) but
  the Xcode project references it, so a fresh clone does not build until it is
  fetched — the command is in `.gitignore`. Without the file Firebase fails to
  start and the app runs with analytics silently off.
- To watch events reach Firebase on a simulator: build with
  `--dart-define=ANALYTICS=true`, install, then
  `xcrun simctl launch <udid> com.furkanozarar.fingerroulette -FIRAnalyticsDebugEnabled -FIRDebugEnabled`
  and read `simctl spawn <udid> log stream --level debug`. Debug-level lines
  are not kept, so `log show` afterwards finds nothing.

## Project Notes

- The iOS target is universal (`TARGETED_DEVICE_FAMILY = "1,2"`). Once a
  universal build is released, App Store Connect does not allow going back to
  iPhone-only. The iPad entry in `Info.plist` has to list all four
  orientations: with fewer, upload validation rejects the build for missing
  iPad multitasking support.
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
- Finger count depends on the window, not the device: `SelectionScreen.maxPlayersFor`
  offers up to 10 when the shortest side is 600 points or more (an iPhone only
  reports five touches, an iPad eleven) and 5 otherwise, which includes a
  narrowed iPad window.
- The screens are laid out for a phone. On a tablet `TabletScale`, installed in
  `MaterialApp.builder`, draws the whole app on a smaller logical screen and
  scales it up (at most 1.5×) instead of each screen adapting itself. Everything
  below it — pointer positions, `MediaQuery`, bottom sheets — sees the logical
  size; code that needs the real window size asks `TabletScale.realSizeOf`.
- Team count is only a choice with a name list: `teamCount` is 2 with fingers
  (five fingers would leave a third team with one person; the iPad's ten still
  get two teams) and up to 4 with names, as long as every team gets at least
  two people. The selection screen
  asks only when more than two teams are possible; otherwise it shows the plain
  continue button.
- Name lists: the controller keeps `lists` and `activeListIndex`, and `names`
  is just the open list — the wheel and the draw never see the others. There
  is always at least one list; deleting the last one empties it instead.
  `NamesService` stores them as JSON and still reads the single list of 1.2 and
  earlier, once, so an update does not lose anyone's names. An unnamed list is
  shown as "List 2" by position; that label is localized, so it is never stored.
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
  `GameController` so tests can substitute fakes. They are created and
  initialised in `main()` before `runApp`.
- The two user settings live in the services that act on them — sound in
  `SoundService`, usage statistics in `StatsService` — and `SettingsSheet`
  only shows their switches. Muting covers sound only; haptics are fired by the
  controller and stay on.
- Sharing is a UI concern, so it stays out of the controller: `ShareButton`
  captures the `RepaintBoundary` that `HomeScreen`'s `captureKey` marks (the
  result without its buttons) and `ShareService` draws it onto a 1080×1920
  story card with the app icon and name. The capture is drawn as a rounded
  panel on purpose — a winner's glow is clipped at the screen edge, and without
  a frame that cut shows up as a hard line in the middle of the card.
- Analytics goes through one seam: `StatsService.logEvent`. `StatsService`
  knows nothing about Firebase — `main()` hands it a sink built by
  `connectFirebaseAnalytics()`, and with no sink (tests, the screenshot run)
  events go nowhere. Debug builds do not send either, so reports only show real
  users; pass `--dart-define=ANALYTICS=true` to try it. Screens are reported by
  hand from `HomeScreen` because all three live in one route, and Firebase's own
  screen tracking is switched off in `Info.plist`.
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
  Also translate the photo permission text in `ios/Runner/InfoPlist.xcstrings`;
  iOS only offers "Save Image" in the share sheet because that key exists.
- `test/localization_test.dart` fails if any locale is missing a key or leaves
  an unresolved ICU placeholder.

## Before Finishing

- Run `flutter analyze` after Dart or Flutter changes when practical.
- Run `flutter test` — the suite covers game flow, review-prompt gating, and
  localization completeness.
