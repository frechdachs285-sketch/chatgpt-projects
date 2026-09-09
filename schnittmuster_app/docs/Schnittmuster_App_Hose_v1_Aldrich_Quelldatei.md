# Schnittmuster-App – Hose v1
## Quelldatei: Aldrich-Regeln, eigene Digitalregeln und bestätigter Entwicklungsstand

Stand: 9. September 2026
Branch: `schnittmuster-hose-v1`
Referenzgröße: 14

## 1. Hauptquelle
Winifred Aldrich, *Metric Pattern Cutting for Women’s Wear*, 5. Auflage.

Für Hose v1 verwendeter Grundschnitt:
- „Classic tailored trouser block“
- Seiten 100–101

Für den geraden Bund:
- Seite 98

Diese Quelle ist die fachliche Grundlage nur für Regeln, die tatsächlich daraus übernommen und im Projekt geprüft wurden.

## 2. Verwendete Eingabemaße
- Taillenumfang
- Hüftumfang
- Hüfttiefe
- Sitzhöhe / Body Rise
- Taille bis Boden
- fertige Saumweite je Hosenbein

Alle Maße werden in Zentimetern verarbeitet.

## 3. Übernommene Aldrich-Punktkonstruktion P0–P31
Wichtige im Projekt digital hinterlegte Beziehungen:

- P0 = Ausgangspunkt auf der Mittellinie
- P1 = Sitzhöhenlinie
- P2 = Hüfttiefenlinie
- P4 = Knielinie nach Aldrich-Beziehung
- P5: Abstand aus Hüftumfang / 12 + 1,5 cm
- P6 liegt senkrecht zu P5 auf der Hüftlinie
- P7 liegt auf der Taillenlinie über P5
- P8 = P6 + Hüftumfang / 4 + 0,5 cm
- P9 = P5 − (Hüftumfang / 16 + 0,5 cm)
- P10 = P7 + 1,0 cm
- P11 = P10 + Taillenumfang / 4 + 2,25 cm

Saum-/Kniebereich:
- halbe Saumweite minus 0,5 cm bildet die Grundbreite der Vorderhose
- P12 und P14 liegen auf der ursprünglichen Aldrich-Saumlinie
- P13/P15 verwenden den größenabhängigen Aldrich-Kniezuschlag
- P26/P28 liegen jeweils 1,0 cm weiter außen als P12/P14
- P27/P29 liegen jeweils 1,0 cm weiter außen als P13/P15

Hinterhose:
- P16 = P5 plus ein Viertel der Strecke 1–5
- P17/P18 liegen senkrecht zu P16 auf Hüft-/Taillenlinie
- P19 ist die Mitte zwischen P16 und P18
- P20 = P18 + 2,0 cm
- P21 = P20 um 2,0 cm angehoben
- hintere Taillenlänge P21–P22 = Taillenumfang / 4 + 4,25 cm
- P23/P24 werden aus der Schrittkonstruktion abgeleitet
- P25 = P17 + Hüftumfang / 4 + 1,5 cm
- P30 und P31 teilen P21–P22 in Drittel

Hinweis: Die App verwendet ein eigenes Koordinatensystem (x nach rechts, y nach unten). Die geometrischen Beziehungen werden dadurch nicht verändert.

## 4. Aldrich-Abnäher
Quelle: 5. Auflage, Seite 100.

Vorderhose:
- Mittelpunkt am Projektpunkt P0
- Breite: 2,0 cm
- Länge: 10,0 cm

Hinterhose:
- P30: Breite 2,0 cm, Länge 12,0 cm, rechtwinklig zu P21–P22
- P31: Breite 2,0 cm, Länge 10,0 cm, rechtwinklig zu P21–P22

## 5. Größenabhängige Aldrich-Regeln
Unterstützte Konstruktionsgrößen:
6, 8, 10, 12, 14, 16, 18, 20, 22, 24

Vorderer Schritt-Hilfswert:
- Größe 6–8: 2,75 cm
- Größe 10–14: 3,00 cm
- Größe 16–20: 3,25 cm
- Größe 22–24: 3,50 cm

Hinterer Schritt-Hilfswert:
- Größe 6–8: 4,00 cm
- Größe 10–14: 4,25 cm
- Größe 16–20: 4,50 cm
- Größe 22–24: 4,75 cm

Knieweiten-Zuschlag außen:
- Größe 6–14: 1,30 cm
- Größe 16–20: 1,50 cm
- Größe 22–24: 1,70 cm

Größe 26 ist in Hose v1 bewusst nicht freigeschaltet, weil für alle benötigten größenabhängigen Regeln keine vollständig bestätigte Angabe übernommen wurde.

## 6. Eigene Hose-v1-Digitalregeln – NICHT als Aldrich-Regel ausgeben
Folgende Regeln sind eigene, im Projekt entwickelte oder bestätigte Digitalregeln:

- P3 wird für Hose v1 exakt 1,0 cm unter die ursprüngliche Aldrich-Saumlinie abgesenkt.
- Saumkurve: exakte symmetrische Parabel durch die bestätigten Saumpunkte.
- digitale Interpolation der Schritt-, Seiten- und Innenbeinkurven.
- Nahtzugaben-Offset-Algorithmen und Übergangsberechnungen.
- automatische A4-Kachelung der 1:1-PDF.
- Klebe-/Ausrichtungsmarkierungen und Kontrollquadrat.
- Fadenlauf als digitale Darstellung.
- Größenbeschriftung als digitale Produkt-/Ausgaberegel.

### 6.1 Vorderer Schlitz rechts
Der Schlitz ist ausdrücklich eine eigene Hose-v1-Produktregel und stammt nicht aus dem klassischen Aldrich-Grundschnitt.

Bestätigte Regel:
- nur rechte Vorderhose
- angeschnitten
- Verlauf von P10 bis P6
- Breite exakt 4,0 cm
- Länge aus der tatsächlichen P10–P6-Geometrie
- linke und rechte Vorderhose sind technisch getrennte PatternPieces
- nur die rechte Vorderhose besitzt die Schlitzerweiterung
- die Schlitzerweiterung ist Bestandteil der echten rechten Nahtkontur

### 6.2 Nahtzugabe an der Schlitzerweiterung
Bestätigte digitale Regel:
- obere Kante der Schlitzerweiterung gehört zur Taillenkante und verwendet `waistCm`
- äußere Längskante der Schlitzerweiterung verwendet `normalCm`
- untere Rückführung der Schlitzerweiterung verwendet `normalCm`
- es wird kein zusätzlicher eigener Schlitz-Nahtzugabenwert eingeführt

## 7. Gerader Bund
Quelle für die Bundkonstruktion: Aldrich, Seite 98.

Bestätigter Hose-v1-Stand:
- gerader einteiliger Bund
- fertige Bundbreite: 4,0 cm als bestätigte Hose-v1-Produktentscheidung
- Zuschnittbreite vor Nahtzugabe: 8,0 cm
- Bundlänge entspricht dem eingegebenen Taillenumfang
- die Hosen-Taillenlinie enthält insgesamt 1,0 cm Mehrweite und wird auf den Bund eingehalten
- 4,0 cm Untertritt/Verlängerung
- Markierungen für vordere Mitte, Seitennähte und hintere Mitte
- Bruchlinie in der Mitte der 8,0-cm-Breite

Offen und deshalb bewusst nicht programmiert:
- Nahtzugabe des Bundes

Grund: Für Hose v1 ist dafür noch keine konkrete, fachlich bestätigte Nahtzugabenregel festgelegt. Es wird nichts geschätzt.

## 8. Fertige Schnittteile
Aktuell werden erzeugt:
- Vorderhose links
- Vorderhose rechts mit angeschnittenem 4,0-cm-Schlitz
- Hinterhose
- Gerader Bund

Vorhanden sind außerdem:
- Vorder- und Hinterabnäher
- Fadenlauf
- Schnittteilbeschriftungen
- Größenbeschriftung
- Nahtkontur
- Schneidekontur bei aktivierter Nahtzugabe für Vorder- und Hinterhose

Zusätzliche unbestätigte Passzeichen/Knipse werden nicht ergänzt.

## 9. Nahtzugaben
Für Vorder- und Hinterhose sind getrennte Nahtzugabenwerte vorhanden für:
- normale Kanten: Seitennähte, Innenbein und Schritt
- Taille
- Saum

Die Nahtzugabe kann ein- und ausgeschaltet werden.

Die Schneidekontur wird mathematisch aus der bestätigten Nahtkontur und den jeweiligen Nahtzugaben berechnet.

## 10. Vorschau
Bestätigter Stand:
- linke Vorderhose, rechte Vorderhose und Hinterhose werden getrennt dargestellt
- Schlitzerweiterung ist nur an der rechten Vorderhose sichtbar
- Bund wird separat dargestellt
- Nahtkontur und Schneidekontur sind unterscheidbar
- Fadenlauf und Abnäher sind sichtbar
- Größenbeschriftung ist für die drei Hosenteile zweizeilig dargestellt, um Überlappungen zu vermeiden
- Referenztest Größe 14 auf Android erfolgreich geprüft

## 11. PDF 1:1 und A4-Kachelung
Bestätigter Stand:
- getrennte PDF-Ausgabe für Vorderhose links, Vorderhose rechts, Hinterhose und Bund
- rechte Vorderhose enthält die Schlitzerweiterung
- 1:1-Geometrie wird in Millimeter/PDF-Punkte umgerechnet
- automatische A4-Kachelung
- Seitenkoordinaten wie A1, B1, C1 usw.
- Überlappungs-/Klebebereich und Montagehinweis
- Kontrollquadrat 100 × 100 mm
- Kontrolllinie 200 mm
- Hinweis auf Druck mit 100 % / tatsächlicher Größe
- Größenbeschriftung ist im PDF sichtbar und wurde praktisch geprüft

Der praktische Android-PDF-Test mit Referenzgröße 14 ergab im aktuellen Stand 41 Seiten. Diese Seitenzahl ist kein festgeschriebener Produktwert, sondern ergibt sich aus den aktuellen Schnittmaßen, Schnittteilen und Kachelparametern.

## 12. Praktisch geprüfter Stand
Referenz: Größe 14.

Geprüft und bestätigt:
- App startet und Hose v1 lässt sich berechnen
- linke/rechte Vorderhose sind sichtbar getrennt
- Schlitz erscheint nur rechts
- 4,0-cm-Schlitzregel wird in der App angezeigt
- Schneidekontur inklusive Schlitz ist sichtbar
- Vorschau der Schnittteile funktioniert
- Größenbeschriftungen sind lesbar und überlappen nach der Korrektur nicht mehr
- 1:1-PDF öffnet
- rechte Vorderhose und Hinterhose tragen die Größenbeschriftung im PDF korrekt
- A4-Kachelung und Seitenkennzeichnung sind sichtbar vorhanden

Noch nicht physisch bestätigt:
- tatsächliche Druckmaßhaltigkeit auf Papier

Dafür ist später das 100 × 100-mm-Kontrollquadrat bei 100 % / „Tatsächliche Größe“ auszudrucken und nachzumessen.

## 13. Bewusst offene bzw. gesperrte Punkte
- Größe 26 bleibt gesperrt.
- Bund-Nahtzugabe bleibt offen, bis eine bestätigte Regel vorliegt.
- zusätzliche Passzeichen/Knipse werden ohne bestätigte Grundlage nicht ergänzt.
- Taschen und weitere Modellierungsdetails gehören nicht automatisch zum klassischen Hosengrundschnitt und werden nicht ohne eigene geprüfte Regeln hinzugefügt.
- physischer 1:1-Drucktest steht noch aus.

## 14. Schutz bestehender Projektstände
- Rock v1 bleibt eingefroren und darf für Hose-v1-Änderungen nicht verändert werden.
- Funktionierenden Hose-v1-Code nicht unnötig verändern.
- Neue Regeln zuerst fachlich festlegen, dann programmieren und anschließend per CI und praktischem Test prüfen.

## 15. Quellenregel für die weitere Entwicklung
1. Aldrich wird nur dort als Quelle genannt, wo eine Regel nachweislich aus dem verwendeten Aldrich-Material übernommen wurde.
2. Eigene Digitalregeln werden separat als „Hose-v1-Digitalregel“ dokumentiert.
3. Maße, Formeln oder Konstruktionswerte werden nicht geschätzt.
4. Neue Regeln werden vor der Programmierung fachlich geprüft und bestätigt.
5. Größe 14 bleibt die unveränderte Referenz für Regressionstests; andere Größen verwenden ausschließlich die bestätigten größenabhängigen Aldrich-Werte.

## 16. Technischer Abschlussstand dieser Dokumentation
Letzter funktionaler Code-Commit vor dieser Dokumentation:
- `a59e5ce44f3a6c8fa9b2d62cd7edfec5563f1128`
- Änderung: zweizeilige Größenbeschriftung in der Vorschau

Dazu erfolgreich:
- Schnittmuster App Check #469
- Schnittmuster APK #308

Die praktische Vorschau- und PDF-Kontrolle auf Android wurde anschließend ebenfalls erfolgreich durchgeführt.

Diese Datei dokumentiert den aktuell bestätigten Quellen- und Entwicklungsstand für „Hose v1“ der Schnittmuster-App. Sie ist als Arbeits- und Referenzquelle für die weitere Entwicklung gedacht und ersetzt keine vollständige Wiedergabe des urheberrechtlich geschützten Buches.
