import '../models/puzzle.dart';

const numberPuzzles = <Puzzle>[
  Puzzle(question: 'Wie viele Äpfel siehst du?', emojiLine: '🍎  🍎  🍎', answers: ['2', '3', '4'], correctAnswer: '3'),
  Puzzle(question: 'Wie viele Enten siehst du?', emojiLine: '🦆  🦆', answers: ['1', '2', '3'], correctAnswer: '2'),
  Puzzle(question: 'Wie viele Blumen siehst du?', emojiLine: '🌼  🌼  🌼  🌼  🌼', answers: ['4', '5', '6'], correctAnswer: '5'),
  Puzzle(question: 'Wie viele Autos siehst du?', emojiLine: '🚗  🚗  🚗  🚗', answers: ['2', '3', '4'], correctAnswer: '4'),
  Puzzle(question: 'Welche Zahl kommt nach der 4?', emojiLine: '1  2  3  4  ❓', answers: ['3', '5', '6'], correctAnswer: '5'),
  Puzzle(question: 'Wie viele Sterne siehst du?', emojiLine: '⭐ ⭐ ⭐ ⭐ ⭐ ⭐ ⭐', answers: ['6', '7', '8'], correctAnswer: '7', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Zahl ist größer?', emojiLine: '6       9', answers: ['6', '9', 'Beide'], correctAnswer: '9', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Zwei Äpfel kommen zu drei Äpfeln. Wie viele sind es?', emojiLine: '🍎🍎  +  🍎🍎🍎', answers: ['4', '5', '6'], correctAnswer: '5', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Ein Ball rollt weg. Wie viele bleiben?', emojiLine: '⚽ ⚽ ⚽  ➜  ⚽ weg', answers: ['1', '2', '3'], correctAnswer: '2', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Zahl fehlt?', emojiLine: '2  3  4  ❓  6', answers: ['4', '5', '7'], correctAnswer: '5', difficulty: PuzzleDifficulty.tricky),
];

const animalPuzzles = <Puzzle>[
  Puzzle(question: 'Welches Tier sagt Miau?', emojiLine: '🐶   🐱   🐮', answers: ['🐶', '🐱', '🐮'], correctAnswer: '🐱'),
  Puzzle(question: 'Welches Tier lebt im Wasser?', emojiLine: '🐟   🐔   🐴', answers: ['🐟', '🐔', '🐴'], correctAnswer: '🐟'),
  Puzzle(question: 'Welches Tier hat einen langen Rüssel?', emojiLine: '🐘   🐰   🦊', answers: ['🐘', '🐰', '🦊'], correctAnswer: '🐘'),
  Puzzle(question: 'Welches Tier kann fliegen?', emojiLine: '🐢   🐦   🐷', answers: ['🐢', '🐦', '🐷'], correctAnswer: '🐦'),
  Puzzle(question: 'Welches Tier gibt Milch?', emojiLine: '🐮   🐧   🐸', answers: ['🐮', '🐧', '🐸'], correctAnswer: '🐮'),
  Puzzle(question: 'Welches Tier legt Eier?', emojiLine: '🐔   🐶   🐴', answers: ['🐔', '🐶', '🐴'], correctAnswer: '🐔', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welches Tier trägt sein Haus auf dem Rücken?', emojiLine: '🐌   🐭   🐑', answers: ['🐌', '🐭', '🐑'], correctAnswer: '🐌', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welches Tier ist das größte?', emojiLine: '🐭   🐘   🐱', answers: ['🐭', '🐘', '🐱'], correctAnswer: '🐘', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welches Tier hüpft und hat lange Ohren?', emojiLine: '🐰   🐷   🐟', answers: ['🐰', '🐷', '🐟'], correctAnswer: '🐰', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welches Tier lebt oft auf einem Bauernhof?', emojiLine: '🐄   🐬   🐧', answers: ['🐄', '🐬', '🐧'], correctAnswer: '🐄', difficulty: PuzzleDifficulty.tricky),
];

const colorPuzzles = <Puzzle>[
  Puzzle(question: 'Welche Farbe hat eine Erdbeere meistens?', emojiLine: '🍓', answers: ['Rot', 'Blau', 'Grün'], correctAnswer: 'Rot'),
  Puzzle(question: 'Welche Farbe hat die Sonne in Kinderbildern oft?', emojiLine: '☀️', answers: ['Gelb', 'Lila', 'Schwarz'], correctAnswer: 'Gelb'),
  Puzzle(question: 'Welche Farbe hat Gras meistens?', emojiLine: '🌱', answers: ['Grün', 'Rosa', 'Orange'], correctAnswer: 'Grün'),
  Puzzle(question: 'Welche Farbe hat eine Orange?', emojiLine: '🍊', answers: ['Orange', 'Blau', 'Grau'], correctAnswer: 'Orange'),
  Puzzle(question: 'Welche Farbe hat Schnee meistens?', emojiLine: '❄️', answers: ['Weiß', 'Braun', 'Rot'], correctAnswer: 'Weiß'),
  Puzzle(question: 'Welche Farbe entsteht aus Blau und Gelb?', emojiLine: '🔵 + 🟡 = ❓', answers: ['Grün', 'Rot', 'Lila'], correctAnswer: 'Grün', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Farbe passt zum Himmel an einem klaren Tag?', emojiLine: '☁️  ☀️', answers: ['Blau', 'Braun', 'Schwarz'], correctAnswer: 'Blau', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Farbe entsteht aus Rot und Gelb?', emojiLine: '🔴 + 🟡 = ❓', answers: ['Orange', 'Grün', 'Blau'], correctAnswer: 'Orange', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Farbe ist am dunkelsten?', emojiLine: '⬜  🩶  ⬛', answers: ['Weiß', 'Grau', 'Schwarz'], correctAnswer: 'Schwarz', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Farbe haben reife Bananen meistens?', emojiLine: '🍌', answers: ['Gelb', 'Blau', 'Rosa'], correctAnswer: 'Gelb', difficulty: PuzzleDifficulty.tricky),
];

const missingPuzzles = <Puzzle>[
  Puzzle(question: 'Was fehlt in der Reihe?', emojiLine: '🍎   🍌   🍎   ❓', answers: ['🍌', '🍓', '🍐'], correctAnswer: '🍌'),
  Puzzle(question: 'Was fehlt in der Reihe?', emojiLine: '⭐   🌙   ⭐   ❓', answers: ['☀️', '🌙', '☁️'], correctAnswer: '🌙'),
  Puzzle(question: 'Was fehlt in der Reihe?', emojiLine: '🐶   🐱   🐶   ❓', answers: ['🐱', '🐭', '🐰'], correctAnswer: '🐱'),
  Puzzle(question: 'Was fehlt in der Reihe?', emojiLine: '🔵   🔺   🔵   ❓', answers: ['🔺', '🟩', '⭐'], correctAnswer: '🔺'),
  Puzzle(question: 'Was fehlt in der Reihe?', emojiLine: '🚗   🚌   🚗   ❓', answers: ['🚲', '🚌', '🚕'], correctAnswer: '🚌'),
  Puzzle(question: 'Was fehlt?', emojiLine: '🍓 🍓 🍌   🍓 🍓 ❓', answers: ['🍓', '🍌', '🍎'], correctAnswer: '🍌', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Form fehlt?', emojiLine: '🔵 🔵 🔺   🔵 🔵 ❓', answers: ['🔺', '🟦', '⭐'], correctAnswer: '🔺', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was kommt als Nächstes?', emojiLine: '🌙 ⭐ ⭐ 🌙 ⭐ ⭐ ❓', answers: ['🌙', '⭐', '☀️'], correctAnswer: '🌙', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was kommt als Nächstes?', emojiLine: '🐶 🐱 🐭 🐶 🐱 ❓', answers: ['🐶', '🐭', '🐰'], correctAnswer: '🐭', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Zahl fehlt?', emojiLine: '1  2  1  2  1  ❓', answers: ['1', '2', '3'], correctAnswer: '2', difficulty: PuzzleDifficulty.tricky),
];

const shapePuzzles = <Puzzle>[
  Puzzle(question: 'Welche Form ist rund?', emojiLine: '🔵   🟥   🔺', answers: ['Kreis', 'Quadrat', 'Dreieck'], correctAnswer: 'Kreis'),
  Puzzle(question: 'Welche Form hat drei Ecken?', emojiLine: '🔺', answers: ['Dreieck', 'Kreis', 'Quadrat'], correctAnswer: 'Dreieck'),
  Puzzle(question: 'Welche Form hat vier gleich lange Seiten?', emojiLine: '🟦', answers: ['Quadrat', 'Kreis', 'Dreieck'], correctAnswer: 'Quadrat'),
  Puzzle(question: 'Welche Form sieht aus wie ein Ei?', emojiLine: '🥚', answers: ['Oval', 'Stern', 'Quadrat'], correctAnswer: 'Oval'),
  Puzzle(question: 'Welche Form hat ein Stoppschild ungefähr?', emojiLine: '🛑', answers: ['Achteck', 'Kreis', 'Dreieck'], correctAnswer: 'Achteck'),
  Puzzle(question: 'Welche Form hat keine Ecken?', emojiLine: '⭕', answers: ['Kreis', 'Rechteck', 'Dreieck'], correctAnswer: 'Kreis', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Form hat mehr Ecken?', emojiLine: '🔺   🟦', answers: ['Dreieck', 'Quadrat', 'Gleich viele'], correctAnswer: 'Quadrat', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Form passt in die Reihe?', emojiLine: '🔵 🔺 🔵 🔺 ❓', answers: ['🔵', '🟩', '⭐'], correctAnswer: '🔵', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Wie viele Ecken hat ein Quadrat?', emojiLine: '🟦', answers: ['3', '4', '5'], correctAnswer: '4', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welche Form ähnelt einem Fenster?', emojiLine: '🪟', answers: ['Rechteck', 'Kreis', 'Dreieck'], correctAnswer: 'Rechteck', difficulty: PuzzleDifficulty.tricky),
];

const oppositePuzzles = <Puzzle>[
  Puzzle(question: 'Was ist das Gegenteil von groß?', emojiLine: '🐘  ↔  🐭', answers: ['Klein', 'Laut', 'Schnell'], correctAnswer: 'Klein'),
  Puzzle(question: 'Was ist das Gegenteil von heiß?', emojiLine: '🔥  ↔  ❄️', answers: ['Kalt', 'Hell', 'Weich'], correctAnswer: 'Kalt'),
  Puzzle(question: 'Was ist das Gegenteil von oben?', emojiLine: '⬆️  ↔  ❓', answers: ['Unten', 'Links', 'Vorne'], correctAnswer: 'Unten'),
  Puzzle(question: 'Was ist das Gegenteil von hell?', emojiLine: '☀️  ↔  🌙', answers: ['Dunkel', 'Warm', 'Schnell'], correctAnswer: 'Dunkel'),
  Puzzle(question: 'Was ist das Gegenteil von voll?', emojiLine: '🥛  ↔  🥛', answers: ['Leer', 'Groß', 'Kalt'], correctAnswer: 'Leer'),
  Puzzle(question: 'Was ist das Gegenteil von schnell?', emojiLine: '🏎️  ↔  🐌', answers: ['Langsam', 'Leise', 'Klein'], correctAnswer: 'Langsam', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was ist das Gegenteil von laut?', emojiLine: '📢  ↔  🤫', answers: ['Leise', 'Hart', 'Dunkel'], correctAnswer: 'Leise', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was ist das Gegenteil von offen?', emojiLine: '🚪  ↔  🚪', answers: ['Geschlossen', 'Leer', 'Kurz'], correctAnswer: 'Geschlossen', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was ist das Gegenteil von nass?', emojiLine: '💧  ↔  ☀️', answers: ['Trocken', 'Kalt', 'Rund'], correctAnswer: 'Trocken', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Was ist das Gegenteil von schwer?', emojiLine: '🏋️  ↔  🪶', answers: ['Leicht', 'Lang', 'Dunkel'], correctAnswer: 'Leicht', difficulty: PuzzleDifficulty.tricky),
];

const letterPuzzles = <Puzzle>[
  Puzzle(question: 'Mit welchem Buchstaben beginnt Apfel?', emojiLine: '🍎', answers: ['A', 'E', 'O'], correctAnswer: 'A'),
  Puzzle(question: 'Mit welchem Buchstaben beginnt Maus?', emojiLine: '🐭', answers: ['M', 'N', 'W'], correctAnswer: 'M'),
  Puzzle(question: 'Mit welchem Buchstaben beginnt Sonne?', emojiLine: '☀️', answers: ['S', 'F', 'Z'], correctAnswer: 'S'),
  Puzzle(question: 'Mit welchem Buchstaben beginnt Ball?', emojiLine: '⚽', answers: ['B', 'P', 'D'], correctAnswer: 'B'),
  Puzzle(question: 'Mit welchem Buchstaben beginnt Hund?', emojiLine: '🐶', answers: ['H', 'K', 'R'], correctAnswer: 'H'),
  Puzzle(question: 'Welches Wort beginnt mit K?', emojiLine: '🐱  🐶  🐭', answers: ['Katze', 'Hund', 'Maus'], correctAnswer: 'Katze', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welcher Buchstabe fehlt?', emojiLine: 'A  B  ❓  D', answers: ['C', 'E', 'F'], correctAnswer: 'C', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welches Wort beginnt mit F?', emojiLine: '🐟  🐱  🦆', answers: ['Fisch', 'Katze', 'Ente'], correctAnswer: 'Fisch', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Mit welchem Buchstaben beginnt Eis?', emojiLine: '🍦', answers: ['E', 'I', 'A'], correctAnswer: 'E', difficulty: PuzzleDifficulty.tricky),
  Puzzle(question: 'Welcher Buchstabe kommt nach D?', emojiLine: 'A  B  C  D  ❓', answers: ['E', 'F', 'G'], correctAnswer: 'E', difficulty: PuzzleDifficulty.tricky),
];

const allCategoryIds = <String>[
  'numbers',
  'animals',
  'colors',
  'missing',
  'shapes',
  'opposites',
  'letters',
];
