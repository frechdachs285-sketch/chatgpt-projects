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
  State<EnglishLearningPuzzleScreen> createState() =>
      _EnglishLearningPuzzleScreenState();
}

class _EnglishLearningPuzzleScreenState
    extends State<EnglishLearningPuzzleScreen> {
  final SpeechService _speech = SpeechService();
  final ProgressService _progress = ProgressService();
  final SettingsService _settings = SettingsService();

  int _index = 0;
  int _stars = 0;
  int _speechSequence = 0;
  bool _answered = false;
  bool _advancing = false;
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

  bool _speechStillCurrent(int sequence) {
    return mounted && sequence == _speechSequence;
  }

  Future<void> _speakQuestion() async {
    final sequence = ++_speechSequence;
    await _speech.stop();

    await _speech.speak(puzzle.question, language: puzzle.speechLanguage);
    if (!_speechStillCurrent(sequence)) return;

    final targetLanguage = puzzle.targetSpeechLanguage ?? 'en-GB';
    for (var i = 0; i < _answers.length; i++) {
      await _speech.speak(
        'Antwort ${i + 1}',
        language: puzzle.speechLanguage,
      );
      if (!_speechStillCurrent(sequence)) return;

      await _speech.speak(
        _answers[i],
        language: targetLanguage,
      );
      if (!_speechStillCurrent(sequence)) return;
    }
  }

  Future<void> _feedback(String answer) async {
    if (_answered) return;

    final sequence = ++_speechSequence;
    await _speech.stop();

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

    if (!_speechStillCurrent(sequence)) return;
    await _speech.speak(
      correct ? 'Juhu! Super gemacht!' : 'Fast! Die richtige Antwort ist markiert.',
      language: puzzle.speechLanguage,
    );
    if (!_speechStillCurrent(sequence)) return;

    await _speech.speak(
      puzzle.speakTarget ?? puzzle.correctAnswer,
      language: puzzle.targetSpeechLanguage ?? 'en-GB',
    );
  }

  Future<void> _next() async {
    if (_advancing) return;
    setState(() => _advancing = true);

    _speechSequence++;
    await _speech.stop();

    if (_index == widget.puzzles.length - 1) {
      await _finish();
      return;
    }

    setState(() {
      _index++;
      _answered = false;
      _selected = null;
      _prepareAnswers();
      _advancing = false;
    });
    await _speakQuestion();
  }

  Future<void> _finish() async {
    await _progress.addStars(_stars);
    await _progress.saveCompletedCount(
      widget.categoryId,
      widget.puzzles.length,
    );
    final normalized =
        ((_stars / widget.puzzles.length) * widget.maxCategoryStars).round();
    await _progress.saveBestStars(widget.categoryId, normalized);

    final sequence = ++_speechSequence;
    await _speech.stop();
    await _speech.speak(
      'Geschafft! Du hast $_stars von ${widget.puzzles.length} Sternen gesammelt.',
      language: 'de-DE',
    );
    if (!_speechStillCurrent(sequence)) return;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Geschafft! 🎉'),
        content: Text('⭐ $_stars von ${widget.puzzles.length} Sternen'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Juhu!'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _speechSequence++;
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⭐ $_stars',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      compact ? 8 : 12,
                      18,
                      18,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: (_index + 1) / widget.puzzles.length,
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFFECEAF8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_index + 1}/${widget.puzzles.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 7 : 10),
                        if (puzzle.difficulty == PuzzleDifficulty.tricky) ...[
                          const MoxBadge(
                            size: 30,
                            message: 'Knifflig? Mox tüftelt mit!',
                          ),
                          SizedBox(height: compact ? 6 : 8),
                        ],
                        RaetseliMascot(
                          message: !_answered
                              ? 'Ich lese die Aufgabe vor und spreche die englischen Wörter für dich.'
                              : isCorrect
                                  ? 'Jaaa! Genau richtig! ⭐'
                                  : 'Fast! Die richtige Antwort ist markiert 🙂',
                          celebrate: _answered && isCorrect,
                          onSpeak: _speakQuestion,
                          mascotSize: compact ? 68 : 80,
                          mascotEmojiSize: compact ? 40 : 48,
                          messageFontSize: compact ? 14 : 15,
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: compact ? 14 : 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Text(
                            puzzle.question,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 21 : 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 9 : 14),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            puzzle.emojiLine,
                            style: TextStyle(fontSize: compact ? 48 : 56),
                          ),
                        ),
                        SizedBox(height: compact ? 9 : 14),
                        ..._answers.asMap().entries.map((entry) {
                          final answer = entry.value;
                          final correct = answer == puzzle.correctAnswer;
                          final chosen = answer == _selected;
                          Color? background;
                          if (_answered && correct) {
                            background = const Color(0xFFDDF5E6);
                          }
                          if (_answered && chosen && !correct) {
                            background = const Color(0xFFFFD4D4);
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: compact ? 7 : 9),
                            child: SizedBox(
                              width: double.infinity,
                              height: compact ? 56 : 60,
                              child: FilledButton.tonal(
                                onPressed:
                                    _answered ? null : () => _feedback(answer),
                                style: FilledButton.styleFrom(
                                  backgroundColor: background,
                                  disabledBackgroundColor: background,
                                  disabledForegroundColor:
                                      const Color(0xFF2B2B3A),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      child: Text('${entry.key + 1}'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        answer,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: compact ? 20 : 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    if (_answered && correct)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF258A4B),
                                      ),
                                    if (_answered && chosen && !correct)
                                      const Icon(
                                        Icons.cancel_rounded,
                                        color: Color(0xFFD64A4A),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (!compact) const Spacer(),
                        if (_answered) ...[
                          SizedBox(height: compact ? 3 : 8),
                          SizedBox(
                            width: double.infinity,
                            height: compact ? 54 : 56,
                            child: FilledButton(
                              onPressed: _advancing ? null : _next,
                              child: Text(
                                _index == widget.puzzles.length - 1
                                    ? 'Fertig 🎉'
                                    : 'Weiter ➜',
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
