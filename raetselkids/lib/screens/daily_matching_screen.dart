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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;

            return Stack(
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
                  padding: EdgeInsets.fromLTRB(
                    18,
                    compact ? 6 : 10,
                    18,
                    compact ? 12 : 18,
                  ),
                  child: Column(
                    children: [
                      RaetseliMascot(
                        message: finished
                            ? (_earnedStar
                                ? 'Super! Dein Tagesstern ist da! ⭐'
                                : 'Super! Heute schon geschafft! 🎉')
                            : 'Finde immer zwei Dinge, die zusammengehören. 👆',
                        mascotSize: compact ? 58 : 72,
                        mascotEmojiSize: compact ? 35 : 43,
                        messageFontSize: compact ? 13 : 15,
                      ),
                      SizedBox(height: compact ? 7 : 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: compact ? 9 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0B8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          _puzzle.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 19 : 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF302E48),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 12),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: leftItems
                                    .map((item) => _leftButton(item, compact))
                                    .toList(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 3 : 6,
                              ),
                              child: Text(
                                '↔️',
                                style: TextStyle(fontSize: compact ? 22 : 28),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: rightItems
                                    .map((item) => _rightButton(item, compact))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: compact ? 9 : 12,
                        ),
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
                          style: TextStyle(
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (finished) ...[
                        SizedBox(height: compact ? 6 : 10),
                        SizedBox(
                          width: double.infinity,
                          height: compact ? 48 : 56,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Zurück ⭐',
                              style: TextStyle(
                                fontSize: compact ? 17 : 19,
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
            );
          },
        ),
      ),
    );
  }

  Widget _leftButton(String item, bool compact) {
    final solved = _solved.contains(item);
    final selected = _selectedLeft == item;

    return SizedBox(
      width: double.infinity,
      height: compact ? 68 : 92,
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
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
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
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            solved ? '$item ✓' : item,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rightButton(String item, bool compact) {
    final solved = _solved.any((left) => _puzzle.pairs[left] == item);

    return SizedBox(
      width: double.infinity,
      height: compact ? 68 : 92,
      child: FilledButton.tonal(
        onPressed: solved ? null : () => _chooseRight(item),
        style: FilledButton.styleFrom(
          backgroundColor: solved ? const Color(0xFFDDF5E6) : Colors.white,
          disabledBackgroundColor: const Color(0xFFDDF5E6),
          disabledForegroundColor: const Color(0xFF2B2B3A),
          padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: Color(0x18A68DFF), width: 2),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            solved ? '$item ✓' : item,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w900,
            ),
          ),
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
