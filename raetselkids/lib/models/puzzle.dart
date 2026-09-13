enum PuzzleDifficulty { easy, tricky }

class Puzzle {
  final String question;
  final String emojiLine;
  final List<String> answers;
  final String correctAnswer;
  final PuzzleDifficulty difficulty;
  final String speechLanguage;
  final String? speakTarget;
  final String? targetSpeechLanguage;

  const Puzzle({
    required this.question,
    required this.emojiLine,
    required this.answers,
    required this.correct