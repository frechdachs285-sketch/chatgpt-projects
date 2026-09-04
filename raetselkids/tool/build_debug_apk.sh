#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
flutter pub get
flutter build apk --debug
printf '\nAPK: %s\n' "$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
