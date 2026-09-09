# Schnittmuster-App – Hose v1
## Quelldatei: Aldrich-Regeln, eigene Digitalregeln und bestätigter Entwicklungsstand

Stand: 9. September 2026
Branch: `hose-v1-erweiterung`
Referenzgröße: 14

## 1. Hauptquelle
Winifred Aldrich, *Metric Pattern Cutting for Women’s Wear*, 5. Auflage.

Für Hose v1 verwendeter Grundschnitt:
- „Classic tailored trouser block“
- Seiten 100–101

Für Bundvarianten und Belege:
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

Zusätzliche optionale Hose-v1-Eingaben:
- Bundtiefe für den geformten Bund
- Belegtiefe für den geformten Bund

Diese beiden Tiefen sind frei wählbare digitale App-Eingaben. Für sie wird keine konkrete Aldrich-Zahl behauptet.

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
- frei wählbare Bundtiefe für den geformten Bund.
- frei wählbare Belegtiefe für den geformten Bund.

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
Quelle für die Grundidee der Bundkonstruktion: Aldrich, Seite 98.

Bestätigter Hose-v1-Stand:
- gerader einteiliger Bund
- fertige Bundbreite: 4,0 cm als bestätigte Hose-v1-Produktentscheidung
- Zuschnittbreite vor Nahtzugabe: 8,0 cm
- Bundlänge entspricht dem eingegebenen Taillenumfang
- die Hosen-Taillenlinie enthält insgesamt 1,0 cm Mehrweite und wird auf den Bund eingehalten
- 4,0 cm Untertritt/Verlängerung
- Markierungen für vordere Mitte, Seitennähte und hintere Mitte
- Bruchlinie in der Mitte der 8,0-cm-Breite

Weiterhin offen und deshalb bewusst nicht programmiert:
- Nahtzugabe des geraden Bundes

Grund: Für den geraden Bund ist in Hose v1 weiterhin keine eigene konkrete Nahtzugabenregel festgelegt. Es wird nichts geschätzt.

## 8. Geformter Bund und Beleg
Quelle für die fachliche Grundidee: Aldrich, Seite 98.

Aus der Quelle übernommen bzw. als fachlicher Rahmen verwendet:
- geformte Bundteile können körpernah aus der Taillen-/oberen Hüftgeometrie abgeleitet werden
- geformte Bundteile werden einzeln zugeschnitten und belegt
- Belege können als getrennte Teile konstruiert werden

Nicht als konkrete Aldrich-Maßregel ausgeben:
- die in der App eingegebene Bundtiefe
- die in der App eingegebene Belegtiefe
- die digitale Kurven-/Offset-Berechnung
- die 1,5-cm-Nahtzugabenregel

### 8.1 Geformter Bund – bestätigte Hose-v1-Digitalregel
- Bundtiefe ist frei wählbar und wird in cm eingegeben
- geformter Bund wird in zwei Schnittteilen erzeugt: vorn und hinten
- die bestätigte Nähkontur bleibt unverändert
- bei aktivierter Nahtzugabe wird eine separate Schneidekontur erzeugt
- Nahtzugabe des geformten Bundes: 1,5 cm rundherum
- bei deaktivierter Nahtzugabe wird nur die Nähkontur ausgegeben
- Vorschau AN/AUS auf Android praktisch bestätigt

### 8.2 Beleg des geformten Bundes – bestätigte Hose-v1-Digitalregel
- Belegtiefe ist frei wählbar und wird in cm eingegeben
- Beleg wird in zwei Schnittteilen erzeugt: vorn und hinten
- die bestätigte Beleg-Nähkontur bleibt unverändert
- bei aktivierter Nahtzugabe wird eine separate Schneidekontur erzeugt
- Nahtzugabe des Belegs: 1,5 cm rundherum
- bei deaktivierter Nahtzugabe wird nur die Nähkontur ausgegeben
- Vorschau AN/AUS auf Android praktisch bestätigt

### 8.3 Auswahlregel gerader/geformter Bund
Bestätigte digitale Produktregel:
- Feld „Bundtiefe geformter Bund“ leer → gerader Bund wird verwendet
- Bundtiefe eingegeben → geformter Bund vorn + hinten ersetzt den geraden Bund in der 1:1-PDF
- Belegtiefe zusätzlich eingegeben → Beleg vorn + hinten wird zusätzlich in die 1:1-PDF aufgenommen

## 9. Fertige Schnittteile
Aktuell werden abhängig von der gewählten Bundvariante erzeugt:
- Vorderhose links
- Vorderhose rechts mit angeschnittenem 4,0-cm-Schlitz
- Hinterhose
- gerader Bund oder geformter Bund vorn + hinten
- optional Beleg vorn + hinten zum geformten Bund

Vorhanden sind außerdem:
- Vorder- und Hinterabnäher
- Fadenlauf
- Schnittteilbeschriftungen
- Größenbeschriftung
- Nahtkontur
- Schneidekontur bei aktivierter Nahtzugabe für Vorder- und Hinterhose
- Schneidekontur bei aktivierter Nahtzugabe für geformten Bund und Beleg

Zusätzliche unbestätigte Passzeichen/Knipse werden nicht ergänzt.

## 10. Nahtzugaben
Für Vorder- und Hinterhose sind getrennte Nahtzugabenwerte vorhanden für:
- normale Kanten: Seitennähte, Innenbein und Schritt
- Taille
- Saum

Zusätzlich bestätigte feste Hose-v1-Digitalregeln:
- geformter Bund: 1,5 cm rundherum
- Beleg geformter Bund: 1,5 cm rundherum

Weiterhin offen:
- Nahtzugabe des geraden Bundes

Die Nahtzugabe kann global ein- und ausgeschaltet werden.

Die Schneidekontur wird mathematisch aus der bestätigten Nahtkontur und den jeweiligen Nahtzugaben berechnet.

## 11. Vorschau
Bestätigter Stand:
- linke Vorderhose, rechte Vorderhose und Hinterhose werden getrennt dargestellt
- Schlitzerweiterung ist nur an der rechten Vorderhose sichtbar
- gerader Bund wird separat dargestellt
- geformter Bund vorn/hinten wird separat dargestellt, wenn eine Bundtiefe eingegeben wurde
- Beleg vorn/hinten wird separat dargestellt, wenn eine Belegtiefe eingegeben wurde
- Nahtkontur und Schneidekontur sind unterscheidbar
- Nahtzugabe AN/AUS funktioniert auch für geformten Bund und Beleg
- Fadenlauf und Abnäher sind sichtbar
- Größenbeschriftung ist für die drei Hosenteile zweizeilig dargestellt, um Überlappungen zu vermeiden
- Referenztest Größe 14 auf Android erfolgreich geprüft

## 12. PDF 1:1 und A4-Kachelung
Bestätigter Stand:
- getrennte PDF-Ausgabe für Vorderhose links, Vorderhose rechts und Hinterhose
- rechte Vorderhose enthält die Schlitzerweiterung
- bei geradem Bund: gerader Bund wird ausgegeben
- bei geformtem Bund: geformter Bund vorn + hinten ersetzt den geraden Bund
- bei zusätzlicher Belegtiefe: Beleg vorn + hinten wird zusätzlich ausgegeben
- geformter Bund und Beleg übernehmen die bestätigte 1,5-cm-Schneidekontur bei Nahtzugabe AN
- bei Nahtzugabe AUS wird für geformten Bund und Beleg nur die Nähkontur ausgegeben
- 1:1-Geometrie wird in Millimeter/PDF-Punkte umgerechnet
- automatische A4-Kachelung
- Seitenkoordinaten wie A1, B1, C1 usw.
- Überlappungs-/Klebebereich und Montagehinweis
- Kontrollquadrat 100 × 100 mm
- Kontrolllinie 200 mm
- Hinweis auf Druck mit 100 % / tatsächlicher Größe
- Größenbeschriftung ist im PDF sichtbar

Praktischer Android-PDF-Test mit Referenzgröße 14:
- geformter Bund ohne geraden Bund praktisch bestätigt
- Beleg vorn/hinten praktisch bestätigt
- Nahtzugabe AN praktisch bestätigt
- Nahtzugabe AUS praktisch bestätigt
- mit geformtem Bund + Beleg wurden im getesteten Stand 44 Seiten angezeigt

Die Seitenzahl ist kein festgeschriebener Produktwert. Sie ergibt sich aus Schnittmaßen, gewählten Schnittteilen, Nahtzugaben und Kachelparametern.

## 13. Praktisch geprüfter Stand
Referenz: Größe 14.

Geprüft und bestätigt:
- App startet und Hose v1 lässt sich berechnen
- linke/rechte Vorderhose sind sichtbar getrennt
- Schlitz erscheint nur rechts
- 4,0-cm-Schlitzregel wird in der App angezeigt
- Schneidekontur inklusive Schlitz ist sichtbar
- Vorschau der Schnittteile funktioniert
- Größenbeschriftungen sind lesbar und überlappen nach der Korrektur nicht mehr
- geformter Bund vorn/hinten wird korrekt dargestellt
- geformter Bund: Nahtzugabe AN/AUS praktisch bestätigt
- Beleg vorn/hinten wird korrekt dargestellt
- Beleg: Nahtzugabe AN/AUS praktisch bestätigt
- 1:1-PDF öffnet
- geformter Bund ersetzt den geraden Bund bei eingetragener Bundtiefe
- Beleg vorn/hinten erscheint bei zusätzlicher Belegtiefe in der PDF
- Beleg-PDF mit Nahtzugabe AN/AUS praktisch bestätigt
- A4-Kachelung und Seitenkennzeichnung sind sichtbar vorhanden

Noch nicht physisch bestätigt:
- tatsächliche Druckmaßhaltigkeit auf Papier

Dafür ist später das 100 × 100-mm-Kontrollquadrat bei 100 % / „Tatsächliche Größe“ auszudrucken und nachzumessen.

## 14. Bewusst offene bzw. gesperrte Punkte
- Größe 26 bleibt gesperrt.
- Nahtzugabe des geraden Bundes bleibt offen, bis eine bestätigte Regel vorliegt.
- zusätzliche Passzeichen/Knipse werden ohne bestätigte Grundlage nicht ergänzt.
- Taschen und weitere Modellierungsdetails gehören nicht automatisch zum klassischen Hosengrundschnitt und werden nicht ohne eigene geprüfte Regeln hinzugefügt.
- physischer 1:1-Drucktest steht noch aus.

## 15. Schutz bestehender Projektstände
- Rock v1 bleibt eingefroren und darf für Hose-v1-Änderungen nicht verändert werden.
- Funktionierenden Hose-v1-Code nicht unnötig verändern.
- Neue Regeln zuerst fachlich festlegen, dann programmieren und anschließend per CI und praktischem Test prüfen.
- Aldrich-Regeln und eigene Hose-v1-Digitalregeln bleiben ausdrücklich getrennt dokumentiert.

## 16. Quellenregel für die weitere Entwicklung
1. Aldrich wird nur dort als Quelle genannt, wo eine Regel nachweislich aus dem verwendeten Aldrich-Material übernommen wurde.
2. Eigene Digitalregeln werden separat als „Hose-v1-Digitalregel“ dokumentiert.
3. Maße, Formeln oder Konstruktionswerte werden nicht geschätzt.
4. Neue Regeln werden vor der Programmierung fachlich geprüft und bestätigt.
5. Größe 14 bleibt die unveränderte Referenz für Regressionstests; andere Größen verwenden ausschließlich die bestätigten größenabhängigen Aldrich-Werte.

## 17. Technischer Abschlussstand dieser Dokumentation
Aktueller funktionaler Code-Stand für die Beleg-PDF-Integration:
- `371d05f3787c35a2e62c9a46ec513446151a1ba4`
- Änderung: angewendete Belegtiefe wird an den 1:1-PDF-Exporter übergeben

Vorheriger zugehöriger PDF-Commit:
- `399369aee1f1a3a93c1137197dc4b4f26e2fce32`
- Änderung: Beleg vorn + hinten als 1:1-PDF-Schnittteile integriert

Dazu erfolgreich:
- Schnittmuster App Check #504
- Schnittmuster APK #343

Die praktische Vorschau- und PDF-Kontrolle auf Android wurde anschließend für geformten Bund und Beleg sowohl mit Nahtzugabe AN als auch AUS erfolgreich durchgeführt.

Diese Datei dokumentiert den aktuell bestätigten Quellen- und Entwicklungsstand für „Hose v1“ der Schnittmuster-App. Sie ist als Arbeits- und Referenzquelle für die weitere Entwicklung gedacht und ersetzt keine vollständige Wiedergabe des urheberrechtlich geschützten Buches.
