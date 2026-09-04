enum PuzzleDifficulty { easy, tricky }

class Puzzle {
  final String question;
  final String emojiLine;
  final List<String> answers;
  final String correctAnswer;
  final PuzzleDifficulty difficulty;

  const Puzzle({
    required this.question,
    required this.emojiLine,
    required this.answers,
    required this.correctAnswer,
    this.difficulty = PuzzleDifficulty.easy,
  });
}
