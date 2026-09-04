# RätselKids v0.6 – Android-Testversion vorbereiten

Diese Version enthält die komplette Flutter-App aus v0.5 plus Android-Build-Vorbereitung.

## Enthalten

- App-Version 0.6.0+6
- Branding-Asset unter `assets/branding/app_icon.png`
- Konfiguration für Android Launcher Icon
- Konfiguration für nativen Splashscreen inkl. Android 12+
- Setup-Skript zum Erzeugen der aktuellen Android-Projektstruktur
- Build-Skript für eine Debug-APK

## Einmalige Einrichtung auf einem Rechner mit Flutter

Im Projektordner ausführen:

```bash
bash tool/setup_android.sh
```

Das Skript:

1. erzeugt die Android-Plattformdateien mit der installierten Flutter-Version,
2. lädt die Pakete,
3. setzt den sichtbaren App-Namen auf `RätselKids`,
4. erzeugt App-Icon und Splashscreen,
5. führt `flutter analyze` aus.

## APK bauen

Danach:

```bash
bash tool/build_debug_apk.sh
```

Die Debug-APK liegt anschließend normalerweise unter:

`build/app/outputs/flutter-apk/app-debug.apk`

## Paketkennung

Die Android-Struktur wird mit der Organisation `de.raetselkids` und dem Projektnamen `raetselkids` erzeugt. Flutter erstellt daraus eine eindeutige Android-Anwendungskennung.

## Hinweis

Die Android-Plattformdateien sind absichtlich nicht fest in diesem ZIP vorgegeben. So werden sie von der tatsächlich installierten Flutter-Version erzeugt und sind nicht an eine möglicherweise veraltete Gradle-/Android-Template-Version gebunden.
