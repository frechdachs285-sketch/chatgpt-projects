import 'dart:math';
import 'package:flutter/material.dart';
import '../data/sample_puzzles.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import 'puzzle_screen.dart';

enum RoundMode { easy, tricky, mixed }

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ProgressService _progress = ProgressService();
  final Map<String, int> _best = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = <String, int>{};
    for (final id in allCategoryIds) {
      result[id] = await _progress.getBestStars(id);
    }
    if (!mounted) return;
    setState(() {
      _best
        ..clear()
        ..addAll(result);
    });
  }

  List<Puzzle> _prepareRound(List<Puzzle> puzzles, RoundMode mode) {
    final pool = switch (mode) {
      RoundMode.easy => puzzles.where((p) => p.difficulty == PuzzleDifficulty.easy).toList(),
      RoundMode.tricky => puzzles.where((p) => p.difficulty == PuzzleDifficulty.tricky).toList(),
      RoundMode.mixed => List<Puzzle>.from(puzzles),
    };
    pool.shuffle(Random());
    return pool;
  }

  String _modeLabel(RoundMode mode) => switch (mode) {
        RoundMode.easy => 'Leicht',
        RoundMode.tricky => 'Knifflig',
        RoundMode.mixed => 'Gemischt',
      };

  Future<RoundMode?> _chooseMode(String title) {
    return showModalBottomSheet<RoundMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$title – wie schwer?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              _modeButton(context, '🌱', 'Leicht', '5 einfache Rätsel', RoundMode.easy),
              const SizedBox(height: 10),
              _modeButton(context, '🧠', 'Knifflig', '5 schwierigere Rätsel', RoundMode.tricky),
              const SizedBox(height: 10),
              _modeButton(context, '🎲', 'Gemischt', 'Alle 10 Rätsel gemischt', RoundMode.mixed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(BuildContext context, String emoji, String title, String subtitle, RoundMode value) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonal(
        onPressed: () => Navigator.pop(context, value),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPuzzle({
    required String id,
    required String title,
    required String emoji,
    required List<Puzzle> puzzles,
  }) async {
    final mode = await _chooseMode(title);
    if (mode == null || !mounted) return;
    final round = _prepareRound(puzzles, mode);

    if (round.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Für diese Stufe sind gerade keine Rätsel verfügbar.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleScreen(
          categoryId: id,
          title: '$title · ${_modeLabel(mode)}',
          categoryEmoji: emoji,
          puzzles: round,
          maxCategoryStars: puzzles.length,
        ),
      ),
    );
    await _load();
  }

  Widget _categoryCard({
    required String id,
    required String title,
    required String emoji,
    required Color color,
    required List<Puzzle> puzzles,
  }) {
    final best = _best[id] ?? 0;
    final complete = best >= puzzles.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: () => _openPuzzle(id: id, title: title, emoji: emoji, puzzles: puzzles),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 42)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(
                        best == 0 ? '${puzzles.length} Rätsel' : 'Bestleistung: ⭐ $best / ${puzzles.length}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                Text(complete ? '🏅' : '›', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wähle dein Rätsel')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            const Text(
              'Welche Rätselwelt möchtest du entdecken?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Jede Welt hat 10 Rätsel in zwei Stufen.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _categoryCard(id: 'numbers', title: 'Zahlen', emoji: '🔢', color: const Color(0xFFBFE1FF), puzzles: numberPuzzles),
            _categoryCard(id: 'animals', title: 'Tiere', emoji: '🐾', color: const Color(0xFFCBEBC0), puzzles: animalPuzzles),
            _categoryCard(id: 'colors', title: 'Farben', emoji: '🎨', color: const Color(0xFFFFD3E0), puzzles: colorPuzzles),
            _categoryCard(id: 'missing', title: 'Was fehlt?', emoji: '🔍', color: const Color(0xFFFFE3A7), puzzles: missingPuzzles),
            _categoryCard(id: 'shapes', title: 'Formen', emoji: '🔷', color: const Color(0xFFCFE8FF), puzzles: shapePuzzles),
            _categoryCard(id: 'opposites', title: 'Gegensätze', emoji: '↔️', color: const Color(0xFFE6D2FF), puzzles: oppositePuzzles),
            _categoryCard(id: 'letters', title: 'Buchstaben', emoji: '🔤', color: const Color(0xFFFFD7B8), puzzles: letterPuzzles),
          ],
        ),
      ),
    );
  }
}
