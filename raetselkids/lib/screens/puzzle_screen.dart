import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/speech_service.dart';
import '../services/settings_service.dart';
import '../widgets/raetseli_mascot.dart';

class PuzzleScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String categoryEmoji;
  final List<Puzzle> puzzles;
  final int maxCategoryStars;

  const PuzzleScreen({super.key, required this.categoryId, required this.title, required this.categoryEmoji, required this.puzzles, required this.maxCategoryStars});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final ProgressService _progressService = ProgressService();
  final SpeechService _speechService = SpeechService();
  final SettingsService _settingsService = SettingsService();
  int currentIndex = 0;
  int stars = 0;
  bool answered = false;
  String? selectedAnswer;
  late List<String> _currentAnswers;

  static const _badgeNames = <String, String>{
    'numbers': 'Zahlenprofi',
    'animals': 'Tierdetektiv',
    'colors': 'Farbenmeister',
    'missing': 'Musterknacker',
    'shapes': 'Formenfinder',
    'opposites': 'Gegensatz-Genie',
    'letters': 'Buchstabenstar',
  };

  Puzzle get currentPuzzle => widget.puzzles[currentIndex];

  @override
  void initState() {
    super.initState();
    _prepareAnswers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  void _prepareAnswers() {
    _currentAnswers = List<String>.from(currentPuzzle.answers)..shuffle();
  }

  @override
  void dispose() {
    _speechService.stop();
    super.dispose();
  }

  Future<void> _speakQuestion() async {
    final puzzle = currentPuzzle;
    final answers = _currentAnswers.asMap().entries.map((entry) => 'Antwort ${entry.key + 1}: ${entry.value}.').join(' ');
    await _speechService.speak('${puzzle.question}. $answers');
  }

  Future<void> _playCorrectFeedback() async {
    if (!await _settingsService.isSoundEnabled()) return;
    HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await SystemSound.play(SystemSoundType.click);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> _playWrongFeedback() async {
    if (!await _settingsService.isSoundEnabled()) return;
    HapticFeedback.selectionClick();
    await SystemSound.play(SystemSoundType.alert);
  }

  Future<void> checkAnswer(String answer) async {
    if (answered) return;
    final correct = answer == currentPuzzle.correctAnswer;
    setState(() {
      selectedAnswer = answer;
      answered = true;
      if (correct) stars++;
    });
    if (correct) {
      await _playCorrectFeedback();
      await _speechService.speak('Juhu! Super gemacht! Das ist richtig!');
    } else {
      await _playWrongFeedback();
      final correctIndex = _currentAnswers.indexOf(currentPuzzle.correctAnswer) + 1;
      await _speechService.speak('Ups! Fast geschafft. Richtig ist Antwort $correctIndex: ${currentPuzzle.correctAnswer}.');
    }
  }

  Future<void> nextPuzzle() async {
    if (currentIndex >= widget.puzzles.length - 1) {
      await _finishRound();
      return;
    }
    setState(() {
      currentIndex++;
      answered = false;
      selectedAnswer = null;
      _prepareAnswers();
    });
    await _speakQuestion();
  }

  Future<void> _finishRound() async {
    final previousBest = await _progressService.getBestStars(widget.categoryId);
    await _progressService.addStars(stars);
    await _progressService.saveCompletedCount(widget.categoryId, widget.puzzles.length);
    final normalizedStars = ((stars / widget.puzzles.length) * widget.maxCategoryStars).round();
    final newBest = await _progressService.saveBestStars(widget.categoryId, normalizedStars);
    final perfect = stars == widget.puzzles.length;
    final firstPerfect = perfect && previousBest < widget.maxCategoryStars;
    final badgeName = _badgeNames[widget.categoryId] ?? '${widget.title}-Profi';

    if (firstPerfect) {
      await _speechService.speak('Wow! Alle Rätsel richtig! Du bekommst das Abzeichen $badgeName!');
    } else if (perfect) {
      await _speechService.speak('Wow! Wieder alle Rätsel richtig! Dein Abzeichen $badgeName glänzt weiter!');
    } else {
      await _speechService.speak('Geschafft! Du hast $stars von ${widget.puzzles.length} Sternen gesammelt.');
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(firstPerfect ? 'Neues Abzeichen! 🏆' : perfect ? 'Schon wieder perfekt! ✨' : 'Geschafft! 🎉'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          if (perfect) ...[
            Container(
              width: 108,
              height: 108,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFD76A), Color(0xFFFFF3BD)]),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0B42D), width: 4),
                boxShadow: const [BoxShadow(blurRadius: 16, offset: Offset(0, 6), color: Color(0x33000000))],
              ),
              child: Text(widget.categoryEmoji, style: const TextStyle(fontSize: 54)),
            ),
            const SizedBox(height: 14),
            Text(firstPerfect ? 'Abzeichen freigeschaltet!' : 'Dein Abzeichen glänzt weiter!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF7A5B00))),
            const SizedBox(height: 4),
            Text(badgeName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('⭐ $stars von ${widget.puzzles.length} · Alles richtig!', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ] else ...[
            const Text('🤩', style: TextStyle(fontSize: 62)),
            const SizedBox(height: 10),
            const Text('Rätseli freut sich mit dir!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(newBest ? 'Neue Bestleistung! ⭐ $stars von ${widget.puzzles.length}' : 'Du hast $stars von ${widget.puzzles.length} Sternen gesammelt.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(firstPerfect ? 'Juhuuu! 🏅' : perfect ? 'Nochmal geschafft! ⭐' : 'Juhu!'))],
      ),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = currentPuzzle;
    final isCorrect = selectedAnswer == puzzle.correctAnswer;
    final mascotText = !answered
        ? 'Ich lese dir die Aufgabe und die Antworten 1, 2 und 3 vor. Tippe auf 🔊 zum Wiederholen.'
        : isCorrect ? 'Jaaa! Genau richtig! ⭐' : 'Fast! Die richtige Antwort ist jetzt markiert 🙂';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryEmoji} ${widget.title}'),
        actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Center(child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFFFE082), borderRadius: BorderRadius.circular(20)),
          child: Text('⭐ $stars', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        )))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: Column(children: [
            ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: (currentIndex + 1) / widget.puzzles.length, minHeight: 12, backgroundColor: const Color(0xFFECEAF8))),
            const SizedBox(height: 8),
            Text('Rätsel ${currentIndex + 1} von ${widget.puzzles.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            RaetseliMascot(message: mascotText, celebrate: answered && isCorrect, onSpeak: _speakQuestion),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
              child: Container(
                key: ValueKey(currentIndex), width: double.infinity, padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 6), color: Color(0x14000000))]),
                child: Text(puzzle.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2B2B3A))),
              ),
            ),
            const Spacer(),
            AnimatedScale(
              scale: answered && isCorrect ? 1.12 : 1.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack,
              child: FittedBox(fit: BoxFit.scaleDown, child: Text(puzzle.emojiLine, textAlign: TextAlign.center, style: const TextStyle(fontSize: 58))),
            ),
            const Spacer(),
            ..._currentAnswers.asMap().entries.map((entry) {
              final number = entry.key + 1;
              final answer = entry.value;
              final chosen = selectedAnswer == answer;
              final answerIsCorrect = answer == puzzle.correctAnswer;
              Color? background;
              if (answered && chosen) {
                background = answerIsCorrect ? const Color(0xFFBDECCF) : const Color(0xFFFFD4D4);
              } else if (answered && answerIsCorrect) {
                background = const Color(0xFFDDF5E6);
              }
              Widget marker = const SizedBox(width: 34);
              if (answered && answerIsCorrect) {
                marker = const Icon(Icons.check_circle_rounded, color: Color(0xFF258A4B), size: 30);
              } else if (answered && chosen) {
                marker = const Icon(Icons.cancel_rounded, color: Color(0xFFD64A4A), size: 30);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity, height: 60,
                  child: FilledButton.tonal(
                    onPressed: answered ? null : () => checkAnswer(answer),
                    style: FilledButton.styleFrom(
                      backgroundColor: background,
                      disabledBackgroundColor: background,
                      disabledForegroundColor: const Color(0xFF2B2B3A),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 38, height: 38, alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFD8D4FF), shape: BoxShape.circle),
                        child: Text('$number', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF4D478C))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(answer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900))),
                      const SizedBox(width: 8),
                      marker,
                    ]),
                  ),
                ),
              );
            }),
            if (answered) ...[
              const SizedBox(height: 3),
              SizedBox(
                width: double.infinity, height: 56,
                child: FilledButton(
                  onPressed: nextPuzzle,
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                  child: Text(currentIndex == widget.puzzles.length - 1 ? 'Fertig 🎉' : 'Weiter ➜', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
