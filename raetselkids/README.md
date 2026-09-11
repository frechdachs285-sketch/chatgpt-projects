# RätselKids v0.9

Kindgerechte Rätsel-App für Kinder ab etwa 5 Jahren.

## Stabil getesteter Stand

- App-Version: `0.9.0+13`
- Getesteter App-Code-Stand: `c8e936196c608944e241da619f31649ea8e571c2`
- GitHub-Actions-Build: Run #91 (`34639978695`)
- Build-Ergebnis: erfolgreich
- APK mit bestehendem stabilem Signierschlüssel signiert: erfolgreich
- Signaturprüfung: erfolgreich
- APK-Artefakt-Upload: erfolgreich
- Echter Android-Handytest: erfolgreich

Dieser Stand gilt als funktionierende v0.9-Sicherungsbasis und darf bei weiteren Änderungen nicht unbeabsichtigt beschädigt werden.

## Enthalten und getestet

- 70 Rätsel
- 7 Rätselwelten: Zahlen, Tiere, Farben, Was fehlt?, Formen, Gegensätze, Buchstaben
- Leicht / Knifflig / Gemischt
- zufällige Rätsel- und Antwortreihenfolge
- Sterne
- Bestleistungen
- Fortschritt
- Abzeichen und Erfolge
- Rätseli als Hauptfigur
- deutsche Sprachausgabe
- Aufgabe und Antwortmöglichkeiten werden vorgelesen
- Wiederholen per Sprachtaste
- freundliche Rückmeldungen bei richtigen und falschen Antworten
- grüne/rötliche Antwortmarkierungen
- Sound und Haptik
- geschützter Elternbereich
- Tagesrätsel mit einmaligem Tagesstern
- Einführung beim ersten Start
- lokale Speicherung
- `SharedPreferencesAsync` inklusive Migration alter gespeicherter Daten
- Neustart und Datenpersistenz erfolgreich getestet

## Mox in v0.9

Mox ergänzt Rätseli, ersetzt Rätseli aber nicht.

- echtes Mox-Bild aus `assets/branding/app_icon.png`
- Mox auf der Startseite
- Mox bei kniffligen Rätseln
- wechselnde kindgerechte Tüftler-Sprüche
- Mox-Spruch wechselt beim Antippen
- keine Lösungshinweise
- kein Einfluss auf Sterne, Antworten oder Fortschritt
- Darstellung auf dem getesteten Android-Gerät erfolgreich geprüft

## Tagesrätsel und Haptik

Die beiden Tagesrätsel beachten jetzt die Eltern-Einstellung „Sounds & Haptik“.

Auf dem echten Android-Gerät bestätigt:

- „Sounds & Haptik“ AUS: keine Vibration im Tagesrätsel
- „Sounds & Haptik“ EIN: Haptik funktioniert wieder
- Tagesstern-Logik unverändert

## Speicher-Test

Nach vollständigem Beenden und erneutem Öffnen der App blieben erhalten:

- Sterne
- Bestleistungen
- Fortschritt
- Abzeichen
- Einstellungen

## Build und Signierung

Der GitHub-Actions-Workflow `.github/workflows/build-raetselkids-apk.yml` verwendet weiterhin den bestehenden stabilen Signierschlüssel. Dieser darf nicht ersetzt oder verändert werden, damit zukünftige APKs weiterhin über die vorhandene App installiert werden können.

Für die Android-Schritte siehe `README_ANDROID.md`.
