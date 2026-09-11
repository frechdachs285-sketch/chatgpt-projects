import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/progress_service.dart';
import '../services/speech_service.dart';
import '../services/settings_service.dart';
import '../widgets/raetseli_mascot.dart';

class DailyMatchingScreen extends StatefulWidget {
  const DailyMatchingScreen({super.key});

  @override
  State<DailyMatchingScreen> createState() => _DailyMatchingScreenState();
}

class _DailyMatchingScreenState extends State<DailyMatchingScreen> {
  final SpeechService _speech = SpeechService();
  final ProgressService _progress = ProgressService();
  final SettingsService _settings = SettingsService();
  late final _MatchingPuzzle _puzzle;
  String? _selectedLeft;
  final Set<String> _solved = {};
  bool _earnedStar = false;

  static const _puzzles = <_MatchingPuzzle>[
    _MatchingPuzzle(title: 'Wer frisst was?', pairs: {
      '🐰 Hase': '🥕 Karotte',
      '🐵 Affe': '🍌 Banane',
      '🐭 Maus': '🧀 Käse',
    }),
    _MatchingPuzzle(title: 'Was gehört zusammen?', pairs: {
      '🪥 Zahnbürste': '🦷 Zahn',
      '🔑 Schlüssel': '🚪 Tür',
      '☂️ Regenschirm': '🌧️ Regen',
    }),
    _MatchingPuzzle(title: 'Tier und Zuhause', pairs: {
      '🐦 Vogel': '🪺 Nest',
      '🐝 Biene': '🍯 Bienenstock',
      '🐶 Hund': '🏠 Hundehütte',
    }),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayKey = DateTime(now.year, now.month, now.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    _puzzle = _puzzles[dayKey % _puzzles.length];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speech.speak(
        '${_puzzle.title}. Tippe links etwas an und finde dann rechts, was dazu gehört.',
      );
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<void> _haptic(Future<void> Function() feedback) async {
    if (!await _settings.isSoundEnabled()) return;
    await feedback();
  }

  Future<void> _chooseRight(String right) async {
    final left = _selectedLeft;
    if (left == null || _solved.contains(left)) return;

    if (_puzzle.pairs[left] == right) {
      await _haptic(HapticFeedback.mediumImpact);
      setState(() {
        _solved.add(left);
        _selectedLeft = null;
      });

      if (_solved.length == _puzzle.pairs.length) {
        final earned = await _progress.completeDailyPuzzle();
        if (mounted) setState(() => _earnedStar = earned);
        await _speech.speak(
          earned
              ? 'Juhuuu! Alles richtig zugeordnet. Du bekommst deinen Tagesstern!'
              : 'Juhuuu! Alles richtig zugeordnet. Das Tagesrätsel hast du heute schon geschafft!',
        );
      } else {
        await _speech.speak('Richtig! Das gehört zusammen.');
      }
    } else {
      await _haptic(HapticFeedback.selectionClick);
      await _speech.speak('Fast! Probiere noch einmal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final finished = _solved.length == _puzzle.pairs.length;
    final leftItems = _puzzle.pairs.keys.toList();
    final rightItems = _puzzle.pairs.values.toList().reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(title: const Text('🎁 Tagesrätsel')),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 34,
              right: 14,
              child: Opacity(
                opacity: .38,
                child: Text('⭐', style: TextStyle(fontSize: 25)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
              child: Column(
                children: [
                  RaetseliMascot(
                    message: finished
                        ? (_earnedStar
                            ? 'Super! Dein Tagesstern ist da! ⭐'
                            : 'Super! Heute schon geschafft! 🎉')
                        : 'Finde immer zwei Dinge, die zusammengehören. 👆',
                    mascotSize: 72,
                    mascotEmojiSize: 43,
                    messageFontSize: 15,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0B8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _puzzle.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF302E48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: leftItems.map(_leftButton).toList(),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text('↔️', style: TextStyle(fontSize: 28)),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: rightItems.map(_rightButton).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: finished
                          ? const Color(0xFFDDF5E6)
                          : const Color(0xFFEFE8FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      finished
                          ? (_earnedStar
                              ? '⭐ +1 Tagesstern!'
                              : '✓ Tagesrätsel geschafft!')
                          : _selectedLeft == null
                              ? '👈 Wähle links'
                              : '👉 Jetzt rechts',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (finished) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Zurück ⭐',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftButton(String item) {
    final solved = _solved.contains(item);
    final selected = _selectedLeft == item;

    return SizedBox(
      width: double.infinity,
      height: 92,
      child: FilledButton.tonal(
        onPressed: solved
            ? null
            : () async {
                await _haptic(HapticFeedback.lightImpact);
                if (!mounted) return;
                setState(() => _selectedLeft = item);
              },
        style: FilledButton.styleFrom(
          backgroundColor: selected
              ? const Color(0xFFD8D4FF)
              : solved
                  ? const Color(0xFFDDF5E6)
                  : Colors.white,
          disabledBackgroundColor: const Color(0xFFDDF5E6),
          disabledForegroundColor: const Color(0xFF2B2B3A),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(
              color: selected
                  ? const Color(0xFF8C82CF)
                  : const Color(0x18A68DFF),
              width: 2,
            ),
          ),
        ),
        child: Text(
          solved ? '$item ✓' : item,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget _rightButton(String item) {
    final solved = _solved.any((left) => _puzzle.pairs[left] == item);

    return SizedBox(
      width: double.infinity,
      height: 92,
      child: FilledButton.tonal(
        onPressed: solved ? null : () => _chooseRight(item),
        style: FilledButton.styleFrom(
          backgroundColor: solved ? const Color(0xFFDDF5E6) : Colors.white,
          disabledBackgroundColor: const Color(0xFFDDF5E6),
          disabledForegroundColor: const Color(0xFF2B2B3A),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Color(0x18A68DFF), width: 2),
          ),
        ),
        child: Text(
          solved ? '$item ✓' : item,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MatchingPuzzle {
  final String title;
  final Map<String, String> pairs;

  const _MatchingPuzzle({required this.title, required this.pairs});
}
