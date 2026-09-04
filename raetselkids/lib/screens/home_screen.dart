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
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ergebnis'),
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFFE082), borderRadius: BorderRadius.circular(22)),
                  child: Text('⭐ $_totalStars', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
              ),
              const Spacer(),
              const RaetseliMascot(message: 'Hallo! Ich bin Rätseli. Wollen wir zusammen knobeln?'),
              const SizedBox(height: 14),
              const Text('🧩', style: TextStyle(fontSize: 62)),
              const Text('RätselKids', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF2B2B3A))),
              const SizedBox(height: 6),
              Text('$totalPossible Rätsel warten auf dich!', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Leicht · Knifflig · Gemischt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              BigMenuButton(emoji: '▶️', label: 'Spielen', backgroundColor: const Color(0xFFB8E7D0), onPressed: _openCategories),
              const SizedBox(height: 12),
              BigMenuButton(emoji: '🏆', label: 'Meine Erfolge', backgroundColor: const Color(0xFFFFE39A), onPressed: _showAchievements),
              const SizedBox(height: 12),
              BigMenuButton(emoji: '⚙️', label: 'Elternbereich', backgroundColor: const Color(0xFFD8D4FF), onPressed: _openParentsArea),
              const Spacer(),
              const Text('Für kleine Knobelfans ab 5 Jahren', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
