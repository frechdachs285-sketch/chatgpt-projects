# Hose v1 – Alternative Beinform

Stand: 9. September 2026
Branch: `hose-v1-erweiterung`
Referenzgröße für Tests: 14

## Quellenregel

Quelle: Winifred Aldrich, *Metric Pattern Cutting for Women’s Wear*, 5. Auflage, Seiten 100–101, Abschnitt/Diagramm „Alternative leg shaping“.

Aus Aldrich übernommen:
- Für eine klassische alternative Beinform werden auf beiden Seiten jedes Hosenbeins gleiche Beträge hinzugefügt oder abgezogen.
- Betroffen sind Knie- und Saumbereich von Vorder- und Hinterhose.

Aldrich gibt an dieser Stelle keinen festen numerischen Änderungsbetrag vor.

## Bestätigte Hose-v1-Digitalregel

Die App verwendet deshalb einen frei eingegebenen vorzeichenbehafteten Wert `alternativeLegShapingCm` in Zentimetern.

- `0.0` = bestätigter Hose-v1-Grundschnitt unverändert
- positiver Wert = Bein gleichmäßig verbreitern
- negativer Wert = Bein gleichmäßig verschmälern
- nur die x-Koordinate wird verändert
- die y-Koordinate bleibt unverändert

Punktzuordnung bei einem Änderungswert `delta`:
- P12.x += delta
- P13.x += delta
- P14.x -= delta
- P15.x -= delta
- P26.x += delta
- P27.x += delta
- P28.x -= delta
- P29.x -= delta

Alle anderen Referenzpunkte P0–P31 bleiben unverändert.

Der frei wählbare numerische `delta`-Wert ist eine eigene Hose-v1-Digitalregel und darf nicht als konkrete Aldrich-Maßregel bezeichnet werden.

## Technische Umsetzung

- `TrouserMeasurements` enthält `alternativeLegShapingCm` mit Standardwert `0.0`.
- Der Wert muss endlich sein; positive, negative und null Werte sind zulässig.
- Der bestätigte Basispunktbestand wird bei einer Änderung nicht mutiert; für die aktive Geometrie wird eine Kopie verwendet.
- Die aktive Geometrie wird an Vorschau und Schnittteilberechnung weitergegeben.
- In der Hose-v1-Oberfläche gibt es das Eingabefeld „Alternative Beinform“.

## Bestätigte Tests

Praktischer Android-Test mit Referenzgröße 14:
- `0` zeigt den bestätigten Grundschnitt unverändert.
- `+1` verbreitert die Beine im Knie-/Saumbereich.
- `-1` verschmälert die Beine im Knie-/Saumbereich.
- Oberer Hosenbereich, Taille, Hüfte, Schritt und Abnäher bleiben bei diesem Test unverändert.
- Die Nahtzugabe folgt der geänderten Kontur in der Vorschau.

Automatischer Koordinatentest:
- `0.0` ist für alle Punkte P0–P31 identisch zum Grundschnitt.
- bei `+1.0` und `-1.0` ändern sich ausschließlich P12–P15 und P26–P29 in x um den exakt vorgesehenen vorzeichenbehafteten Betrag.
- sämtliche y-Koordinaten bleiben unverändert.
- sämtliche anderen x-Koordinaten bleiben unverändert.

GitHub-Stand:
- Geometrie: Commit `2186ec8ce8a787079c8ef4aaf8f760b475b89f7a`
- UI-Eingabe: Commit `fc7f6f6406b90bf1f1ba03fd07099812af629d16`
- Koordinatentests: Commit `895fae7229f09edd9743f1a349dbf036cad1ce60`
- Schnittmuster App Check #511: erfolgreich

## Status

Alternative Beinform für Hose v1 ist damit fachlich getrennt dokumentiert, praktisch auf Android geprüft und mathematisch durch automatische Koordinatentests abgesichert.
