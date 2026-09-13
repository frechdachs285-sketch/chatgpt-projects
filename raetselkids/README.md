# RätselKids v1.0

Kindgerechte Rätsel-App für Kinder ab etwa 5 Jahren.

## Stabil getesteter Stand

- App-Version: `1.0.0+14`
- Getesteter App-Code-Stand: `cbeefa26aa152daaadc19f345cdcc2fe1cc3651c`
- GitHub-Actions-Build: Run #100 (`34755186603`)
- Build-Ergebnis: erfolgreich
- APK mit bestehendem stabilem Signierschlüssel signiert: erfolgreich
- Signaturprüfung: erfolgreich
- APK-Artefakt-Upload: erfolgreich
- Echter Android-Handytest: erfolgreich
- Sicherungs-Branch: `release/raetselkids-v1.0`

Dieser Stand gilt als funktionierende v1.0-Sicherungsbasis und darf bei weiteren Änderungen nicht unbeabsichtigt beschädigt werden.

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
- Mox als zweite Begleitfigur für knifflige Aufgaben
- deutsche Sprachausgabe
- Aufgabe und Antwortmöglichkeiten werden vorgelesen
- Wiederholen per Sprachtaste
- freundliche Rückmeldungen bei richtigen und falschen Antworten
- grüne/rötliche Antwortmarkierungen
- Sound und Haptik
- geschützter Elternbereich
- Tagesrätsel mit einmaligem Tagesstern
- Einführung beim ersten Start
- „Einführung nochmal zeigen“ im Elternbereich
- lokale Speicherung
- `SharedPreferencesAsync` inklusive Migration alter gespeicherter Daten
- App-Start-Fallback bei Preferences-Fehlern
- Accessibility/Semantics für Rätsel-Fortschritt und Antwortmöglichkeiten
- kompaktere Darstellung auf kleinen Displays
- Neustart und Datenpersistenz erfolgreich getestet

## v1.0-Qualitätsrunde

Zusätzlich zum normalen Funktionsumfang wurden für v1.0 folgende Punkte geprüft bzw. verbessert:

- Flutter für reproduzierbare Android-Builds auf `3.47.3` festgepinnt
- Android-Setup, Paketkennung, App-Name, Icon und Splash geprüft
- bestehender stabiler APK-Signierschlüssel unverändert weiterverwendet
- Update von v0.9 auf v1.0 ohne Verlust von Sternen, Fortschritt oder Einstellungen getestet
- Tagesrätsel, Abzeichen und alle 7 Rätselwelten auf dem echten Android-Gerät geprüft
- Sprache, Sound/Haptik und Elternbereich nach App-Neustart geprüft
- Eltern-Zugang nach falscher Eingabe stabilisiert

## Elternbereich-Fix in v1.0

Beim echten Android-Test wurde ein Flutter-Framework-Absturz nach falscher Eingabe im geschützten Eltern-Zugang gefunden.

Der Zugang wurde anschließend überarbeitet und erneut auf dem Gerät getestet:

- falsche Eingabe: Dialog bleibt offen
- klare Fehlermeldung direkt im Dialog
- erneute Eingabe möglich
- „Zurück“ schließt den Dialog sauber
- richtige Antwort `56` öffnet den Elternbereich
- kein Absturz mehr

Der Fix wurde mit GitHub Actions Run #100 erfolgreich gebaut und anschließend auf dem echten Android-Gerät bestätigt.

## Mox in v1.0

Mox ergänzt Rätseli, ersetzt Rätseli aber nicht.

- Rätseli bleibt die Hauptfigur
- Mox erscheint als zweite Begleitfigur bei kniffligen Aufgaben
- Mox gibt keine Lösungshinweise
- kein Einfluss auf Sterne, Antworten oder Fortschritt

## Speicher-Test

Nach vollständigem Beenden und erneutem Öffnen der App blieben erhalten:

- Sterne
- Bestleistungen
- Fortschritt
- Abzeichen
- Einstellungen

Auch das Update von der zuvor installierten v0.9 auf v1.0 wurde ohne vorherige Deinstallation erfolgreich getestet.

## Build und Signierung

Der GitHub-Actions-Workflow `.github/workflows/build-raetselkids-apk.yml` verwendet weiterhin den bestehenden stabilen Signierschlüssel. Dieser darf niemals ersetzt oder verändert werden, damit zukünftige APKs weiterhin über die vorhandene App installiert werden können.

Der Workflow verwendet für den getesteten v1.0-Stand Flutter `3.47.3`, damit die automatisch erzeugte Android-Basis reproduzierbar bleibt.

Für die Android-Schritte siehe `README_ANDROID.md`.
