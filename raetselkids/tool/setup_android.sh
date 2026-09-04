#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter wurde nicht gefunden. Bitte Flutter installieren und erneut starten."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "1/5 Android-Projektstruktur erzeugen ..."
flutter create . --platforms=android --org de.raetselkids --project-name raetselkids

# flutter create erzeugt einen Standard-Widget-Test, der MyApp erwartet.
# RätselKids verwendet einen eigenen App-Einstiegspunkt, daher darf dieser
# generierte Beispieltest den Build nicht blockieren.
rm -f test/widget_test.dart

echo "2/5 Pakete laden ..."
flutter pub get

echo "3/5 Android-Appname setzen ..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]]; then
  sed -i 's/android:label="raetselkids"/android:label="RätselKids"/' "$MANIFEST" || true
fi

echo "4/5 App-Icon und Splashscreen erzeugen ..."
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create -p flutter_native_splash.yaml

echo "5/5 Projekt prüfen ..."
flutter analyze

echo
echo "Fertig. APK erzeugen mit: flutter build apk --debug"
