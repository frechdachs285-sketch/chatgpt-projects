import '../models/puzzle.dart';

const englishColorPuzzles = <Puzzle>[
  Puzzle(question: 'Which colour is red?', emojiLine: '🎨', answers: ['🟥', '🟦', '🟩'], correctAnswer: '🟥', speechLanguage: 'en-GB', speakTarget: 'red'),
  Puzzle(question: 'Which colour is blue?', emojiLine: '🎨', answers: ['🟨', '🟦', '🟧'], correctAnswer: '🟦', speechLanguage: 'en-GB', speakTarget: 'blue'),
  Puzzle(question: 'Which colour is green?', emojiLine: '🎨', answers: ['🟩', '🟥', '🟪'], correctAnswer: '🟩', speechLanguage: 'en-GB', speakTarget: 'green'),
  Puzzle(question: 'Which colour is yellow?', emojiLine: '🎨', answers: ['🟦', '🟨', '⬛'], correctAnswer: '🟨', speechLanguage: 'en-GB', speakTarget: 'yellow'),
  Puzzle(question: 'Which colour is orange?', emojiLine: '🎨', answers: ['🟧', '🟩', '⬜'], correctAnswer: '🟧', speechLanguage: 'en-GB', speakTarget: 'orange'),
  Puzzle(question: 'Which colour is pink?', emojiLine: '🎨', answers: ['🩷', '🟨', '🟦'], correctAnswer: '🩷', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'pink'),
  Puzzle(question: 'Which colour is purple?', emojiLine: '🎨', answers: ['🟪', '🟧', '🟩'], correctAnswer: '🟪', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'purple'),
  Puzzle(question: 'Which colour is black?', emojiLine: '🎨', answers: ['⬜', '⬛', '🟨'], correctAnswer: '⬛', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'black'),
  Puzzle(question: 'Which colour is white?', emojiLine: '🎨', answers: ['⬜', '🟪', '🟥'], correctAnswer: '⬜', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'white'),
];

const englishNumberPuzzles = <Puzzle>[
  Puzzle(question: 'Which picture shows one?', emojiLine: '🔢', answers: ['⭐', '⭐⭐', '⭐⭐⭐'], correctAnswer: '⭐', speechLanguage: 'en-GB', speakTarget: 'one'),
  Puzzle(question: 'Which picture shows two?', emojiLine: '🔢', answers: ['⭐⭐⭐', '⭐⭐', '⭐'], correctAnswer: '⭐⭐', speechLanguage: 'en-GB', speakTarget: 'two'),
  Puzzle(question: 'Which picture shows three?', emojiLine: '🔢', answers: ['⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐'], correctAnswer: '⭐⭐⭐', speechLanguage: 'en-GB', speakTarget: 'three'),
  Puzzle(question: 'Which picture shows four?', emojiLine: '🔢', answers: ['⭐⭐⭐⭐', '⭐⭐⭐', '⭐⭐⭐⭐⭐'], correctAnswer: '⭐⭐⭐⭐', speechLanguage: 'en-GB', speakTarget: 'four'),
  Puzzle(question: 'Which picture shows five?', emojiLine: '🔢', answers: ['⭐⭐⭐⭐', '⭐⭐⭐⭐⭐', '⭐⭐⭐'], correctAnswer: '⭐⭐⭐⭐⭐', speechLanguage: 'en-GB', speakTarget: 'five'),
  Puzzle(question: 'Which number is six?', emojiLine: '🔢', answers: ['6', '7', '8'], correctAnswer: '6', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'six'),
  Puzzle(question: 'Which number is seven?', emojiLine: '🔢', answers: ['9', '7', '6'], correctAnswer: '7', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'seven'),
  Puzzle(question: 'Which number is eight?', emojiLine: '🔢', answers: ['10', '8', '9'], correctAnswer: '8', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'eight'),
  Puzzle(question: 'Which number is nine?', emojiLine: '🔢', answers: ['7', '10', '9'], correctAnswer: '9', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'nine'),
  Puzzle(question: 'Which number is ten?', emojiLine: '🔢', answers: ['10', '8', '9'], correctAnswer: '10', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'ten'),
];

const englishAnimalPuzzles = <Puzzle>[
  Puzzle(question: 'Which animal is a dog?', emojiLine: '🐾', answers: ['🐶', '🐱', '🐭'], correctAnswer: '🐶', speechLanguage: 'en-GB', speakTarget: 'dog'),
  Puzzle(question: 'Which animal is a cat?', emojiLine: '🐾', answers: ['🐰', '🐱', '🐷'], correctAnswer: '🐱', speechLanguage: 'en-GB', speakTarget: 'cat'),
  Puzzle(question: 'Which animal is a horse?', emojiLine: '🐾', answers: ['🐴', '🐮', '🐷'], correctAnswer: '🐴', speechLanguage: 'en-GB', speakTarget: 'horse'),
  Puzzle(question: 'Which animal is a cow?', emojiLine: '🐾', answers: ['🐸', '🐮', '🐭'], correctAnswer: '🐮', speechLanguage: 'en-GB', speakTarget: 'cow'),
  Puzzle(question: 'Which animal is a pig?', emojiLine: '🐾', answers: ['🐷', '🐰', '🐶'], correctAnswer: '🐷', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'pig'),
  Puzzle(question: 'Which animal is a rabbit?', emojiLine: '🐾', answers: ['🐭', '🐸', '🐰'], correctAnswer: '🐰', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'rabbit'),
  Puzzle(question: 'Which animal is a mouse?', emojiLine: '🐾', answers: ['🐭', '🐱', '🐸'], correctAnswer: '🐭', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'mouse'),
  Puzzle(question: 'Which animal is a frog?', emojiLine: '🐾', answers: ['🐮', '🐸', '🐴'], correctAnswer: '🐸', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'frog'),
];

const englishLetterPuzzles = <Puzzle>[
  Puzzle(question: 'A is for apple. Which picture is an apple?', emojiLine: 'A', answers: ['🍎', '⚽', '🐱'], correctAnswer: '🍎', speechLanguage: 'en-GB', speakTarget: 'apple'),
  Puzzle(question: 'B is for ball. Which picture is a ball?', emojiLine: 'B', answers: ['🐶', '⚽', '🐟'], correctAnswer: '⚽', speechLanguage: 'en-GB', speakTarget: 'ball'),
  Puzzle(question: 'C is for cat. Which picture is a cat?', emojiLine: 'C', answers: ['🐱', '🐘', '🍎'], correctAnswer: '🐱', speechLanguage: 'en-GB', speakTarget: 'cat'),
  Puzzle(question: 'D is for dog. Which picture is a dog?', emojiLine: 'D', answers: ['🐟', '🐶', '⚽'], correctAnswer: '🐶', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'dog'),
  Puzzle(question: 'E is for elephant. Which picture is an elephant?', emojiLine: 'E', answers: ['🐘', '🐱', '🐟'], correctAnswer: '🐘', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'elephant'),
  Puzzle(question: 'F is for fish. Which picture is a fish?', emojiLine: 'F', answers: ['🍎', '🐟', '🐶'], correctAnswer: '🐟', difficulty: PuzzleDifficulty.tricky, speechLanguage: 'en-GB', speakTarget: 'fish'),
];

const englishAllCategoryIds = <String>[
  'english_colors',
  'english_numbers',
  'english_animals',
  'english_letters',
];
