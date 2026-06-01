# AGENTS.md

## Project

Finger Roulette is a Flutter app for a multi-touch party game that randomly picks a winner from up to 5 players.

## Common Commands

- `flutter pub get`
- `flutter analyze`
- `flutter test`

## Project Notes

- Main app code lives in `lib/`.
- Sound assets are listed in `pubspec.yaml` under `assets/sounds/`.
- App icon and splash configuration are managed from `pubspec.yaml`.
- Keep changes small and focused.
- Do not edit generated build output unless explicitly needed.
- Preserve platform folders (`android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`) unless the task is platform-specific.

## Before Finishing

- Run `flutter analyze` after Dart or Flutter changes when practical.
- Run `flutter test` when tests exist or logic changes are introduced.
