import '../models/puzzle.dart';

const englishColorPuzzles = <Puzzle>[
  Puzzle(question: 'Wie heißt Rot auf Englisch?', emojiLine: '🟥', answers: ['red', 'blue', 'green'], correctAnswer: 'red', speechLanguage: 'de-DE', speakTarget: 'red', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Blau auf Englisch?', emojiLine: '🟦', answers: ['yellow', 'blue', 'orange'], correctAnswer: 'blue', speechLanguage: 'de-DE', speakTarget: 'blue', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Grün auf Englisch?', emojiLine: '🟩', answers: ['green', 'red', 'purple'], correctAnswer: 'green', speechLanguage: 'de-DE', speakTarget: 'green', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Gelb auf Englisch?', emojiLine: '🟨', answers: ['blue', 'yellow', 'black'], correctAnswer: 'yellow', speechLanguage: 'de-DE', speakTarget: 'yellow', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Orange auf Englisch?', emojiLine: '🟧', answers: ['orange', 'green', 'white'], correctAnswer: 'orange', speechLanguage: 'de-DE', speakTarget: 'orange', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Rosa auf Englisch?', emojiLine: '🩷', answers: ['pink', 'yellow', 'blue'], correctAnswer: 'pink', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'pink', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Lila auf Englisch?', emojiLine: '🟪', answers: ['purple', 'orange', 'green'], correctAnswer: 'purple', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'purple', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Schwarz auf Englisch?', emojiLine: '⬛', answers: ['white', 'black', 'yellow'], correctAnswer: 'black', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'black', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Weiß auf Englisch?', emojiLine: '⬜', answers: ['white', 'purple', 'red'], correctAnswer: 'white', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'white', targetSpeechLanguage: 'en-GB'),
];

const englishNumberPuzzles = <Puzzle>[
  Puzzle(question: 'Wie heißt Eins auf Englisch?', emojiLine: '1', answers: ['one', 'two', 'three'], correctAnswer: 'one', speechLanguage: 'de-DE', speakTarget: 'one', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Zwei auf Englisch?', emojiLine: '2', answers: ['three', 'two', 'one'], correctAnswer: 'two', speechLanguage: 'de-DE', speakTarget: 'two', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Drei auf Englisch?', emojiLine: '3', answers: ['two', 'three', 'four'], correctAnswer: 'three', speechLanguage: 'de-DE', speakTarget: 'three', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Vier auf Englisch?', emojiLine: '4', answers: ['four', 'three', 'five'], correctAnswer: 'four', speechLanguage: 'de-DE', speakTarget: 'four', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Fünf auf Englisch?', emojiLine: '5', answers: ['four', 'five', 'three'], correctAnswer: 'five', speechLanguage: 'de-DE', speakTarget: 'five', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Sechs auf Englisch?', emojiLine: '6', answers: ['six', 'seven', 'eight'], correctAnswer: 'six', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'six', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Sieben auf Englisch?', emojiLine: '7', answers: ['nine', 'seven', 'six'], correctAnswer: 'seven', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'seven', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Acht auf Englisch?', emojiLine: '8', answers: ['ten', 'eight', 'nine'], correctAnswer: 'eight', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'eight', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Neun auf Englisch?', emojiLine: '9', answers: ['seven', 'ten', 'nine'], correctAnswer: 'nine', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'nine', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Zehn auf Englisch?', emojiLine: '10', answers: ['ten', 'eight', 'nine'], correctAnswer: 'ten', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'ten', targetSpeechLanguage: 'en-GB'),
];

const englishAnimalPuzzles = <Puzzle>[
  Puzzle(question: 'Wie heißt Hund auf Englisch?', emojiLine: '🐶', answers: ['dog', 'cat', 'mouse'], correctAnswer: 'dog', speechLanguage: 'de-DE', speakTarget: 'dog', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Katze auf Englisch?', emojiLine: '🐱', answers: ['rabbit', 'cat', 'pig'], correctAnswer: 'cat', speechLanguage: 'de-DE', speakTarget: 'cat', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Pferd auf Englisch?', emojiLine: '🐴', answers: ['horse', 'cow', 'pig'], correctAnswer: 'horse', speechLanguage: 'de-DE', speakTarget: 'horse', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Kuh auf Englisch?', emojiLine: '🐮', answers: ['frog', 'cow', 'mouse'], correctAnswer: 'cow', speechLanguage: 'de-DE', speakTarget: 'cow', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Schwein auf Englisch?', emojiLine: '🐷', answers: ['pig', 'rabbit', 'dog'], correctAnswer: 'pig', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'pig', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Kaninchen auf Englisch?', emojiLine: '🐰', answers: ['mouse', 'frog', 'rabbit'], correctAnswer: 'rabbit', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'rabbit', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Maus auf Englisch?', emojiLine: '🐭', answers: ['mouse', 'cat', 'frog'], correctAnswer: 'mouse', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'mouse', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Wie heißt Frosch auf Englisch?', emojiLine: '🐸', answers: ['cow', 'frog', 'horse'], correctAnswer: 'frog', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'frog', targetSpeechLanguage: 'en-GB'),
];

const englishLetterPuzzles = <Puzzle>[
  Puzzle(question: 'Welches englische Wort beginnt mit A?', emojiLine: 'A  🍎', answers: ['apple', 'ball', 'cat'], correctAnswer: 'apple', speechLanguage: 'de-DE', speakTarget: 'apple', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Welches englische Wort beginnt mit B?', emojiLine: 'B  ⚽', answers: ['dog', 'ball', 'fish'], correctAnswer: 'ball', speechLanguage: 'de-DE', speakTarget: 'ball', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Welches englische Wort beginnt mit C?', emojiLine: 'C  🐱', answers: ['cat', 'elephant', 'apple'], correctAnswer: 'cat', speechLanguage: 'de-DE', speakTarget: 'cat', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Welches englische Wort beginnt mit D?', emojiLine: 'D  🐶', answers: ['fish', 'dog', 'ball'], correctAnswer: 'dog', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'dog', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Welches englische Wort beginnt mit E?', emojiLine: 'E  🐘', answers: ['elephant', 'cat', 'fish'], correctAnswer: 'elephant', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'elephant', targetSpeechLanguage: 'en-GB'),
  Puzzle(question: 'Welches englische Wort beginnt mit F?', emojiLine: 'F  🐟', answers: ['apple', 'fish', 'dog'], correctAnswer: 'fish', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'de-DE', speakTarget: 'fish', targetSpeechLanguage: 'en-GB'),
];

const englishAllCategoryIds = <String>[
  'english_colors',
  'english_numbers',
  'english_animals',
  'english_letters',
];
