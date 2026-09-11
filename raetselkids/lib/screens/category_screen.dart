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
      backgroundColor: const Color(0xFFFFFCF5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title – wie schwer?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _modeButton(context, '🌱', 'Leicht', '5 Rätsel', const Color(0xFFDDF5E6), RoundMode.easy),
              const SizedBox(height: 10),
              _modeButton(context, '🧠', 'Knifflig', '5 Rätsel', const Color(0xFFFFE3A7), RoundMode.tricky),
              const SizedBox(height: 10),
              _modeButton(context, '🎲', 'Gemischt', '10 Rätsel', const Color(0xFFE6D2FF), RoundMode.mixed),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
    Color color,
    RoundMode value,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: FilledButton(
        onPressed: () => Navigator.pop(context, value),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF302E48),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 31)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _openPuzzle(id: id, title: title, emoji: emoji, puzzles: puzzles),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 38)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF302E48),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (best == 0)
                            Text(
                              '${puzzles.length} Rätsel',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF514F61),
                              ),
                            )
                          else ...[
                            Text(
                              '⭐ $best / ${puzzles.length}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF514F61),
                              ),
                            ),
                            if (complete) ...[
                              const SizedBox(width: 7),
                              const Text('🏅', style: TextStyle(fontSize: 18)),
                            ],
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    complete ? '✓' : '›',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF514F61),
                    ),
                  ),
                ),
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
      appBar: AppBar(title: const Text('Deine Rätselwelten')),
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: 25,
              right: 18,
              child: Opacity(
                opacity: .5,
                child: Text('⭐', style: TextStyle(fontSize: 24)),
              ),
            ),
            const Positioned(
              top: 95,
              left: 12,
              child: Opacity(
                opacity: .35,
                child: Text('🧩', style: TextStyle(fontSize: 28)),
              ),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0B8),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🌈', style: TextStyle(fontSize: 27)),
                      SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Such dir eine Welt aus!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF3D3A58),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _categoryCard(
                  id: 'numbers',
                  title: 'Zahlen',
                  emoji: '🔢',
                  color: const Color(0xFFBFE1FF),
                  puzzles: numberPuzzles,
                ),
                _categoryCard(
                  id: 'animals',
                  title: 'Tiere',
                  emoji: '🐾',
                  color: const Color(0xFFCBEBC0),
                  puzzles: animalPuzzles,
                ),
                _categoryCard(
                  id: 'colors',
                  title: 'Farben',
                  emoji: '🎨',
                  color: const Color(0xFFFFD3E0),
                  puzzles: colorPuzzles,
                ),
                _categoryCard(
                  id: 'missing',
                  title: 'Was fehlt?',
                  emoji: '🔍',
                  color: const Color(0xFFFFE3A7),
                  puzzles: missingPuzzles,
                ),
                _categoryCard(
                  id: 'shapes',
                  title: 'Formen',
                  emoji: '🔷',
                  color: const Color(0xFFCFE8FF),
                  puzzles: shapePuzzles,
                ),
                _categoryCard(
                  id: 'opposites',
                  title: 'Gegensätze',
                  emoji: '↔️',
                  color: const Color(0xFFE6D2FF),
                  puzzles: oppositePuzzles,
                ),
                _categoryCard(
                  id: 'letters',
                  title: 'Buchstaben',
                  emoji: '🔤',
                  color: const Color(0xFFFFD7B8),
                  puzzles: letterPuzzles,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
