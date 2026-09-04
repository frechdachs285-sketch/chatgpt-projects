#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter wurde nicht gefunden."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "1/6 Android-Projektstruktur erzeugen ..."
flutter create . --platforms=android --org de.raetselkids --project-name raetselkids

# Der von Flutter automatisch erzeugte Beispieltest passt nicht zu RätselKids.
rm -f test/widget_test.dart

echo "2/6 Pakete laden ..."
flutter pub get

echo "3/6 Android-Appname setzen ..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]]; then
  sed -i 's/android:label="raetselkids"/android:label="RätselKids"/' "$MANIFEST" || true
fi

echo "4/6 App-Icon und Splashscreen erzeugen ..."
dart run flutter_launcher_icons -f flutter_launcher_icons.yaml
dart run flutter_native_splash:create -p flutter_native_splash.yaml

echo "5/6 Feste APK-Signatur einrichten ..."

: "${RAETSELKIDS_KEYSTORE_BASE64:?RAETSELKIDS_KEYSTORE_BASE64 fehlt}"
: "${RAETSELKIDS_KEY_ALIAS:?RAETSELKIDS_KEY_ALIAS fehlt}"
: "${RAETSELKIDS_KEY_PASSWORD:?RAETSELKIDS_KEY_PASSWORD fehlt}"
: "${RAETSELKIDS_STORE_PASSWORD:?RAETSELKIDS_STORE_PASSWORD fehlt}"

printf '%s' "$RAETSELKIDS_KEYSTORE_BASE64" | base64 --decode > android/app/raetselkids-signing.p12

cat > android/key.properties <<EOF
storePassword=$RAETSELKIDS_STORE_PASSWORD
keyPassword=$RAETSELKIDS_KEY_PASSWORD
keyAlias=$RAETSELKIDS_KEY_ALIAS
storeFile=raetselkids-signing.p12
EOF

python3 <<'PY'
from pathlib import Path

path = Path("android/app/build.gradle.kts")
text = path.read_text()

imports = """import java.io.FileInputStream
import java.util.Properties

"""

if "import java.util.Properties" not in text:
    text = imports + text

props = """
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

"""

if "val keystoreProperties = Properties()" not in text:
    marker = "android {"
    text = text.replace(marker, props + marker, 1)

signing = """
    signingConfigs {
        create("raetselkids") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

"""

if 'create("raetselkids")' not in text:
    marker = "    buildTypes {"
    text = text.replace(marker, signing + marker, 1)

if 'debug {' not in text:
    marker = "    buildTypes {"
    replacement
