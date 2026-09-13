import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../services/speech_service.dart';
import '../widgets/mox_badge.dart';
import '../widgets/raetseli_mascot.dart';

class EnglishLearningPuzzleScreen extends StatefulWidget {
  final String categoryId;
  final String title;
  final String categoryEmoji;
  final List<Puzzle> puzzles;
  final int maxCategoryStars;

  const EnglishLearningPuzzleScreen({
    super.key,
    required this.categoryId,
    required this.title,
    required this.categoryEmoji,
    required this.puzzles,
    required this.maxCategoryStars,
  });

  @override
  State<EnglishLearningPuzzleScreen> createState() => _EnglishLearningPuzzleScreenState();
}

class _EnglishLearningPuzzleScreenState extends State<EnglishLearningPuzzleScreen> {
  final SpeechService _speech = SpeechService();
  final ProgressService _progress = ProgressService();
  final SettingsService _settings = SettingsService();
  int _index = 0;
  int _stars = 0;
  bool _answered = false;
  String? _selected;
  late List<String> _answers;

  Puzzle get puzzle => widget.puzzles[_index];

  @override
  void initState() {
    super.initState();
    _prepareAnswers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakQuestion());
  }

  void _prepareAnswers() {
    _answers = List<String>.from(puzzle.answers)..shuffle();
  }

  Future<void> _speakQuestion() async {
    await _speech.speak(puzzle.question, language: puzzle.speechLanguage);
    final targetLanguage = puzzle.targetSpeechLanguage ?? 'en-GB';
    for (var i = 0; i < _answers.length; i++) {
      await _speech.speak('Antwort ${i + 1}', language: puzzle.speechLanguage);
      await _speech.speak(_answers[i], language: targetLanguage);
    }
  }

  Future<void> _feedback(String answer) async {
    if (_answered) return;
    final correct = answer == puzzle.correctAnswer;
    setState(() {
      _answered = true;
      _selected = answer;
      if (correct) _stars++;
    });

    if (await _settings.isSoundEnabled()) {
      if (correct) {
        HapticFeedback.mediumImpact();
        await SystemSound.play(SystemSoundType.click);
      } else {
        HapticFeedback.selectionClick();
        await SystemSound.play(SystemSoundType.alert);
      }
    }

    await _speech.speak(
      correct ? 'Juhu! Super gemacht!' : 'Fast! Die richtige Antwort ist markiert.',
      language: puzzle.speechLanguage,
    );
    await _speech.speak(
      puzzle.speakTarget ?? puzzle.correctAnswer,
      language: puzzle.targetSpeechLanguage ?? 'en-GB',
    );
  }

  Future<void> _next() async {
    if (_index == widget.puzzles.length - 1) {
      await _finish();
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
      _prepareAnswers();
    });
    await _speakQuestion();
  }

  Future<void> _finish() async {
    await _progress.addStars(_stars);
    await _progress.saveCompletedCount(widget.categoryId, widget.puzzles.length);
    final normalized = ((_stars / widget.puzzles.length) * widget.maxCategoryStars).round();
    await _progress.saveBestStars(widget.categoryId, normalized);
    await _speech.speak(
      'Geschafft! Du hast $_stars von ${widget.puzzles.length} Sternen gesammelt.',
      language: 'de-DE',
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Geschafft! 🎉'),
        content: Text('⭐ $_stars von ${widget.puzzles.length} Sternen'),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Juhu!'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _selected == puzzle.correctAnswer;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(
        title: Text('${widget.categoryEmoji} ${widget.title}'),
        actions: [Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: Text('⭐ $_stars', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
        )],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: LinearProgressIndicator(value: (_index + 1) / widget.puzzles.length, minHeight: 12)),
                const SizedBox(width: 10),
                Text('${_index + 1}/${widget.puzzles.length}', style: const TextStyle(fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 10),
              if (puzzle.difficulty == PuzzleDifficulty.tricky) ...[
                const MoxBadge(size: 30, message: 'Knifflig? Mox tüftelt mit!'),
                const SizedBox(height: 8),
              ],
              RaetseliMascot(
                message: !_answered
                    ? 'Ich lese die Aufgabe vor und spreche die englischen Wörter für dich.'
                    : isCorrect
                        ? 'Jaaa! Genau richtig! ⭐'
                        : 'Fast! Die richtige Antwort ist markiert 🙂',
                celebrate: _answered && isCorrect,
                onSpeak: _speakQuestion,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                child: Text(puzzle.question, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 14),
              Text(puzzle.emojiLine, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 14),
              ..._answers.asMap().entries.map((entry) {
                final answer = entry.value;
                final correct = answer == puzzle.correctAnswer;
                final chosen = answer == _selected;
                Color? background;
                if (_answered && correct) background = const Color(0xFFDDF5E6);
                if (_answered && chosen && !correct) background = const Color(0xFFFFD4D4);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton.tonal(
                      onPressed: _answered ? null : () => _feedback(answer),
                      style: FilledButton.styleFrom(backgroundColor: background, disabledBackgroundColor: background),
                      child: Row(children: [
                        CircleAvatar(child: Text('${entry.key + 1}')),
                        const SizedBox(width: 12),
                        Expanded(child: Text(answer, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                        if (_answered && correct) const Icon(Icons.check_circle_rounded, color: Color(0xFF258A4B)),
                        if (_answered && chosen && !correct) const Icon(Icons.cancel_rounded, color: Color(0xFFD64A4A)),
                      ]),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (_answered)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(_index == widget.puzzles.length - 1 ? 'Fertig 🎉' : 'Weiter ➜', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
