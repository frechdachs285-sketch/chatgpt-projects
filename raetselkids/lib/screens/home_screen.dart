import 'package:flutter/material.dart';
import '../data/sample_puzzles.dart';
import '../services/progress_service.dart';
import '../widgets/big_menu_button.dart';
import '../widgets/raetseli_mascot.dart';
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
    _loadStars();
  }

  Future<void> _loadStars() async {
    final stars = await _progressService.getTotalStars();
    if (!mounted) return;
    setState(() => _totalStars = stars);
  }

  Future<void> _openCategories() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryScreen()));
    await _loadStars();
  }

  Future<void> _showAchievements() async {
    final values = <String, int>{};
    for (final id in allCategoryIds) {
      values[id] = await _progressService.getBestStars(id);
    }
    if (!mounted) return;

    final allPerfect = values.values.every((value) => value >= 10);
    final badges = <String>[
      if (_totalStars >= 10) '⭐ Sternenstarter',
      if (_totalStars >= 50) '🌟 Sternensammler',
      if (_totalStars >= 100) '✨ Rätseli-Freund',
      if ((values['numbers'] ?? 0) >= 10) '🔢 Zahlenprofi',
      if ((values['animals'] ?? 0) >= 10) '🐾 Tierdetektiv',
      if ((values['colors'] ?? 0) >= 10) '🎨 Farbenmeister',
      if ((values['missing'] ?? 0) >= 10) '🔍 Musterknacker',
      if ((values['shapes'] ?? 0) >= 10) '🔷 Formenfinder',
      if ((values['opposites'] ?? 0) >= 10) '↔️ Gegensatz-Genie',
      if ((values['letters'] ?? 0) >= 10) '🔤 Buchstabenstar',
      if (allPerfect) '🏆 Rätselkönig',
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meine Erfolge 🏆'),
        content: SizedBox(
          width: 320,
          child: badges.isEmpty
              ? const Text('Noch kein Abzeichen – spiele eine Rätselwelt und sammle Sterne!', style: TextStyle(fontSize: 18))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('⭐ $_totalStars Sterne insgesamt', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 14),
                      ...badges.map((badge) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(badge, style: const TextStyle(fontSize: 18)),
                          )),
                    ],
                  ),
                ),
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Prima!'))],
      ),
    );
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
            const Text('7 × 8 = ?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ergebnis'),
              onSubmitted: (_) => Navigator.pop(context, controller.text.trim() == '56'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Zurück')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim() == '56'), child: const Text('Öffnen')),
        ],
      ),
    );
    controller.dispose();

    if (allowed != true || !mounted) {
      if (allowed == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Das Ergebnis war noch nicht richtig.')));
      }
      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentsScreen()));
    await _loadStars();
  }

  @override
  Widget build(BuildContext context) {
    final totalPossible = numberPuzzles.length +
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
            Positioned(top: -55, left: -45, child: Container(width: 180, height: 180, decoration: const BoxDecoration(color: Color(0x35FFE39A), shape: BoxShape.circle))),
            Positioned(top: 165, right: -60, child: Container(width: 170, height: 170, decoration: const BoxDecoration(color: Color(0x32D8D4FF), shape: BoxShape.circle))),
            Positioned(bottom: 120, left: -55, child: Container(width: 150, height: 150, decoration: const BoxDecoration(color: Color(0x2FAEE5CB), shape: BoxShape.circle))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.86), borderRadius: BorderRadius.circular(18)),
                        child: const Text('🧩 RätselKids', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF3D3A58))),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD966),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 9, offset: Offset(0, 4))],
                        ),
                        child: Text('⭐ $_totalStars', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const RaetseliMascot(
                    message: 'Hallo! Ich bin Rätseli. Bereit für ein neues Abenteuer?',
                    mascotSize: 104,
                    mascotEmojiSize: 62,
                    messageFontSize: 18,
                  ),
                  const SizedBox(height: 18),
                  const Text('RätselKids', textAlign: TextAlign.center, style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: Color(0xFF302E48), height: 1.0)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(color: const Color(0xFFFFF0B8), borderRadius: BorderRadius.circular(22)),
                    child: Text('$totalPossible Rätsel · 7 Welten · jede Menge Spaß', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF4B463B))),
                  ),
                  const Spacer(),
                  BigMenuButton(
                    emoji: '🚀',
                    label: 'Losspielen!',
                    backgroundColor: const Color(0xFF91DEBC),
                    height: 96,
                    fontSize: 28,
                    emojiSize: 40,
                    onPressed: _openCategories,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: BigMenuButton(
                          emoji: '🏆',
                          label: 'Erfolge',
                          backgroundColor: const Color(0xFFFFE39A),
                          height: 82,
                          fontSize: 18,
                          emojiSize: 27,
                          compact: true,
                          onPressed: _showAchievements,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BigMenuButton(
                          emoji: '⚙️',
                          label: 'Eltern',
                          backgroundColor: const Color(0xFFD8D4FF),
                          height: 82,
                          fontSize: 18,
                          emojiSize: 27,
                          compact: true,
                          onPressed: _openParentsArea,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text('🌟 Für kleine Knobelfans ab 5 Jahren 🌟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF514F61))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
