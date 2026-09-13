import 'package:flutter/material.dart';
import '../data/english_puzzles.dart';
import '../services/progress_service.dart';
import '../widgets/big_menu_button.dart';
import '../widgets/mox_badge.dart';
import '../widgets/raetseli_mascot.dart';
import 'achievements_screen.dart';
import 'category_screen.dart';
import 'parents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressService _progressService = ProgressService();
  int _totalStars = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final stars = await _progressService.getTotalStars();
    if (!mounted) return;
    setState(() => _totalStars = stars);
  }

  Future<void> _openCategories() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoryScreen()),
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
    var answer = '';
    var showError = false;

    final allowed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          void submit() {
            if (answer.trim() == '56') {
              Navigator.pop(dialogContext, true);
              return;
            }
            setDialogState(() => showError = true);
          }

          return AlertDialog(
            scrollable: true,
            title: const Text('Adults only 🔒'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please solve this quick question:'),
                const SizedBox(height: 10),
                const Text(
                  '7 × 8 = ?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Answer',
                    errorText: showError ? 'That answer is not correct yet.' : null,
                  ),
                  onChanged: (value) {
                    answer = value;
                    if (showError) setDialogState(() => showError = false);
                  },
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Back'),
              ),
              FilledButton(
                onPressed: submit,
                child: const Text('Open'),
              ),
            ],
          );
        },
      ),
    );

    if (allowed != true || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ParentsScreen()),
    );
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final totalPossible =
        englishColorPuzzles.length +
        englishNumberPuzzles.length +
        englishAnimalPuzzles.length +
        englishLetterPuzzles.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(top: -58, left: -48, child: _PastelBubble(size: 190, color: Color(0x55FFE39A))),
            const Positioned(top: 155, right: -62, child: _PastelBubble(size: 180, color: Color(0x4DD8D4FF))),
            const Positioned(bottom: 112, left: -52, child: _PastelBubble(size: 155, color: Color(0x4DAEE5CB))),
            const Positioned(top: 86, right: 24, child: _FloatingDecoration(text: '☁️', size: 30, opacity: .72)),
            const Positioned(top: 245, left: 15, child: _FloatingDecoration(text: '⭐', size: 23, opacity: .68)),
            const Positioned(bottom: 265, right: 15, child: _FloatingDecoration(text: '🧩', size: 24, opacity: .55)),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 20, vertical: compact ? 7 : 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 13, vertical: compact ? 6 : 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .9),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0x22A68DFF)),
                                  ),
                                  child: Text(
                                    '🧩 RätselKids English',
                                    style: TextStyle(fontSize: compact ? 13 : 15, fontWeight: FontWeight.w900, color: const Color(0xFF3D3A58)),
                                  ),
                                ),
                                const Spacer(),
                                MoxBadge(size: compact ? 42 : 48, showLabel: true),
                                SizedBox(width: compact ? 6 : 9),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 15, vertical: compact ? 7 : 9),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD966),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 9, offset: Offset(0, 4))],
                                  ),
                                  child: Text('⭐ $_totalStars', style: TextStyle(fontSize: compact ? 18 : 20, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 7 : 10),
                            Container(
                              padding: EdgeInsets.fromLTRB(compact ? 10 : 12, compact ? 8 : 11, compact ? 10 : 12, compact ? 9 : 12),
                              decoration: BoxDecoration(
                                color: const Color(0xEFFFFFFF),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: const Color(0x22A68DFF)),
                                boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 7))],
                              ),
                              child: Column(
                                children: [
                                  RaetseliMascot(
                                    message: 'Hello! Ready for an English puzzle adventure?',
                                    mascotSize: compact ? 68 : 84,
                                    mascotEmojiSize: compact ? 41 : 51,
                                    messageFontSize: compact ? 14 : 16,
                                  ),
                                  SizedBox(height: compact ? 4 : 7),
                                  Text(
                                    'RätselKids English',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: compact ? 34 : 40, fontWeight: FontWeight.w900, color: const Color(0xFF302E48), height: 1),
                                  ),
                                  SizedBox(height: compact ? 5 : 7),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: compact ? 13 : 16, vertical: compact ? 5 : 7),
                                    decoration: BoxDecoration(color: const Color(0xFFFFF0B8), borderRadius: BorderRadius.circular(22)),
                                    child: Text(
                                      '$totalPossible puzzles · 4 worlds',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w800, color: const Color(0xFF4B463B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            BigMenuButton(
                              emoji: '🚀',
                              label: "Let's play!",
                              backgroundColor: const Color(0xFF91DEBC),
                              height: compact ? 70 : 82,
                              fontSize: compact ? 22 : 25,
                              emojiSize: compact ? 32 : 36,
                              onPressed: _openCategories,
                            ),
                            SizedBox(height: compact ? 10 : 12),
                            Row(
                              children: [
                                Expanded(
                                  child: BigMenuButton(
                                    emoji: '🏆',
                                    label: 'Achievements',
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
                                    label: 'Parents',
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
                            Text('⭐  🧩  ⭐', style: TextStyle(fontSize: compact ? 15 : 17)),
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
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _FloatingDecoration extends StatelessWidget {
  final String text;
  final double size;
  final double opacity;
  const _FloatingDecoration({required this.text, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: Text(text, style: TextStyle(fontSize: size)),
      );
}
