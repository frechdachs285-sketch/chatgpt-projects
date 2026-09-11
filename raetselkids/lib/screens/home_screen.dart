import 'package:flutter/material.dart';
import '../data/sample_puzzles.dart';
import '../services/progress_service.dart';
import '../widgets/big_menu_button.dart';
import '../widgets/mox_badge.dart';
import '../widgets/raetseli_mascot.dart';
import 'achievements_screen.dart';
import 'category_screen.dart';
import 'daily_puzzle_screen.dart';
import 'parents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
  int _totalStars = 0;
  bool _dailyDone = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final stars = await _progressService.getTotalStars();
    final dailyDone = await _progressService.isDailyCompletedToday();
    if (!mounted) return;
    setState(() {
      _totalStars = stars;
      _dailyDone = dailyDone;
    });
  }

  Future<void> _openCategories() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryScreen()),
    );
    await _loadProgress();
  }

  Future<void> _openDailyPuzzle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyPuzzleScreen()),
    );
    await _loadProgress();
  }

  Future<void> _showAchievements() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
    );
    await _loadProgress();
  }

  Future<void> _openParentsArea() async {
    final controller = TextEditingController();
    final allowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Nur für Erwachsene 🔒'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bitte löse kurz diese Aufgabe:'),
            const SizedBox(height: 10),
            const Text(
              '7 × 8 = ?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ergebnis',
              ),
              onSubmitted: (_) => Navigator.pop(
                context,
                controller.text.trim() == '56',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zurück'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim() == '56',
            ),
            child: const Text('Öffnen'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (allowed != true || !mounted) {
      if (allowed == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Das Ergebnis war noch nicht richtig.'),
          ),
        );
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParentsScreen()),
    );
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final totalPossible =
        numberPuzzles.length +
        animalPuzzles.length +
        colorPuzzles.length +
        missingPuzzles.length +
        shapePuzzles.length +
        oppositePuzzles.length +
        letterPuzzles.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -58,
              left: -48,
              child: _PastelBubble(
                size: 190,
                color: Color(0x55FFE39A),
              ),
            ),
            const Positioned(
              top: 155,
              right: -62,
              child: _PastelBubble(
                size: 180,
                color: Color(0x4DD8D4FF),
              ),
            ),
            const Positioned(
              bottom: 112,
              left: -52,
              child: _PastelBubble(
                size: 155,
                color: Color(0x4DAEE5CB),
              ),
            ),
            const Positioned(
              top: 86,
              right: 24,
              child: _FloatingDecoration(text: '☁️', size: 30, opacity: .72),
            ),
            const Positioned(
              top: 245,
              left: 15,
              child: _FloatingDecoration(text: '⭐', size: 23, opacity: .68),
            ),
            const Positioned(
              bottom: 265,
              right: 15,
              child: _FloatingDecoration(text: '🧩', size: 24, opacity: .55),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 20,
                          vertical: compact ? 7 : 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 10 : 13,
                                    vertical: compact ? 6 : 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0x22A68DFF)),
                                  ),
                                  child: Text(
                                    '🧩 RätselKids',
                                    style: TextStyle(
                                      fontSize: compact ? 13 : 15,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF3D3A58),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                MoxBadge(
                                  size: compact ? 42 : 48,
                                  showLabel: true,
                                ),
                                SizedBox(width: compact ? 6 : 9),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 12 : 15,
                                    vertical: compact ? 7 : 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD966),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 9,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '⭐ $_totalStars',
                                    style: TextStyle(
                                      fontSize: compact ? 18 : 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 7 : 10),
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                compact ? 10 : 12,
                                compact ? 8 : 11,
                                compact ? 10 : 12,
                                compact ? 9 : 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xEFFFFFFF),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: const Color(0x22A68DFF)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x12000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  RaetseliMascot(
                                    message: 'Hallo! Bereit für ein Rätsel-Abenteuer?',
                                    mascotSize: compact ? 68 : 84,
                                    mascotEmojiSize: compact ? 41 : 51,
                                    messageFontSize: compact ? 14 : 16,
                                  ),
                                  SizedBox(height: compact ? 4 : 7),
                                  Text(
                                    'RätselKids',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: compact ? 34 : 40,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF302E48),
                                      height: 1,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 5 : 7),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: compact ? 13 : 16,
                                      vertical: compact ? 5 : 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0B8),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Text(
                                      '$totalPossible Rätsel · 7 Welten',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: compact ? 13 : 14,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF4B463B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            BigMenuButton(
                              emoji: '🚀',
                              label: 'Losspielen!',
                              backgroundColor: const Color(0xFF91DEBC),
                              height: compact ? 70 : 82,
                              fontSize: compact ? 22 : 25,
                              emojiSize: compact ? 32 : 36,
                              onPressed: _openCategories,
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            BigMenuButton(
                              emoji: _dailyDone ? '✅' : '🎁',
                              label: _dailyDone
                                  ? 'Tagesrätsel geschafft!'
                                  : 'Tagesrätsel · +1 ⭐',
                              backgroundColor: _dailyDone
                                  ? const Color(0xFFDDF5E6)
                                  : const Color(0xFFFFC9DD),
                              height: compact ? 62 : 72,
                              fontSize: compact ? 18 : 20,
                              emojiSize: compact ? 28 : 31,
                              onPressed: _openDailyPuzzle,
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            Row(
                              children: [
                                Expanded(
                                  child: BigMenuButton(
                                    emoji: '🏆',
                                    label: 'Erfolge',
                                    backgroundColor: const Color(0xFFFFE39A),
                                    height: compact ? 62 : 70,
                                    fontSize: compact ? 16 : 17,
                                    emojiSize: compact ? 23 : 25,
                                    compact: true,
                                    onPressed: _showAchievements,
                                  ),
                                ),
                                SizedBox(width: compact ? 9 : 12),
                                Expanded(
                                  child: BigMenuButton(
                                    emoji: '⚙️',
                                    label: 'Eltern',
                                    backgroundColor: const Color(0xFFD8D4FF),
                                    height: compact ? 62 : 70,
                                    fontSize: compact ? 16 : 17,
                                    emojiSize: compact ? 23 : 25,
                                    compact: true,
                                    onPressed: _openParentsArea,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '⭐  🧩  ⭐',
                              style: TextStyle(fontSize: compact ? 15 : 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PastelBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _PastelBubble({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _FloatingDecoration extends StatelessWidget {
  final String text;
  final double size;
  final double opacity;

  const _FloatingDecoration({
    required this.text,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(text, style: TextStyle(fontSize: size)),
    );
  }
}
