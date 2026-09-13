import 'dart:math';
import 'package:flutter/material.dart';
import '../data/english_puzzles.dart';
import '../models/puzzle.dart';
import '../services/progress_service.dart';
import 'english_learning_puzzle_screen.dart';

enum EnglishRoundMode { easy, tricky, mixed }

class EnglishCategoryScreen extends StatefulWidget {
  const EnglishCategoryScreen({super.key});

  @override
  State<EnglishCategoryScreen> createState() => _EnglishCategoryScreenState();
}

class _EnglishCategoryScreenState extends State<EnglishCategoryScreen> {
  final ProgressService _progress = ProgressService();
  final Map<String, int> _best = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = <String, int>{};
    for (final id in englishAllCategoryIds) {
      result[id] = await _progress.getBestStars(id);
    }
    if (!mounted) return;
    setState(() {
      _best
        ..clear()
        ..addAll(result);
    });
  }

  List<Puzzle> _prepareRound(List<Puzzle> puzzles, EnglishRoundMode mode) {
    final pool = switch (mode) {
      EnglishRoundMode.easy =>
        puzzles.where((p) => p.difficulty == PuzzleDifficulty.easy).toList(),
      EnglishRoundMode.tricky =>
        puzzles.where((p) => p.difficulty == PuzzleDifficulty.tricky).toList(),
      EnglishRoundMode.mixed => List<Puzzle>.from(puzzles),
    };
    pool.shuffle(Random());
    return pool;
  }

  String _modeLabel(EnglishRoundMode mode) => switch (mode) {
        EnglishRoundMode.easy => 'Leicht',
        EnglishRoundMode.tricky => 'Knifflig',
        EnglishRoundMode.mixed => 'Gemischt',
      };

  String _progressId(String categoryId, EnglishRoundMode mode) {
    return switch (mode) {
      EnglishRoundMode.easy => '${categoryId}_easy',
      EnglishRoundMode.tricky => '${categoryId}_tricky',
      EnglishRoundMode.mixed => categoryId,
    };
  }

  Future<EnglishRoundMode?> _chooseMode(
    String title,
    List<Puzzle> puzzles,
  ) {
    final easyCount = puzzles
        .where((p) => p.difficulty == PuzzleDifficulty.easy)
        .length;
    final trickyCount = puzzles
        .where((p) => p.difficulty == PuzzleDifficulty.tricky)
        .length;

    return showModalBottomSheet<EnglishRoundMode>(
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _modeButton(
                context,
                '🌱',
                'Leicht',
                '$easyCount Rätsel',
                EnglishRoundMode.easy,
                const Color(0xFFDDF5E6),
              ),
              const SizedBox(height: 10),
              _modeButton(
                context,
                '🧠',
                'Knifflig',
                '$trickyCount Rätsel',
                EnglishRoundMode.tricky,
                const Color(0xFFFFE3A7),
              ),
              const SizedBox(height: 10),
              _modeButton(
                context,
                '🎲',
                'Gemischt',
                '${puzzles.length} Rätsel',
                EnglishRoundMode.mixed,
                const Color(0xFFE6D2FF),
              ),
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
    EnglishRoundMode value,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 68,
      child: FilledButton(
        onPressed: () => Navigator.pop(context, value),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF302E48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
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
    final mode = await _chooseMode(title, puzzles);
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
        builder: (_) => EnglishLearningPuzzleScreen(
          categoryId: _progressId(id, mode),
          title: '$title · ${_modeLabel(mode)}',
          categoryEmoji: emoji,
          puzzles: round,
          maxCategoryStars: round.length,
        ),
      ),
    );
    await _load();
  }

  Widget _categoryCard({
    required String id,
    required String title,
    required String subtitle,
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
          onTap: () => _openPuzzle(
            id: id,
            title: title,
            emoji: emoji,
            puzzles: puzzles,
          ),
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    shape: BoxShape.circle,
                  ),
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
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF302E48),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF514F61),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        best == 0
                            ? '${puzzles.length} Rätsel'
                            : '⭐ $best / ${puzzles.length}${complete ? '  🏅' : ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF514F61),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '›',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF514F61),
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
      appBar: AppBar(title: const Text('🇬🇧 Englisch')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0B8),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Text(
                'Lerne spielerisch erste englische Wörter!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF3D3A58),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _categoryCard(
              id: 'english_colors',
              title: 'Farben',
              subtitle: 'red · blue · green …',
              emoji: '🎨',
              color: const Color(0xFFFFD3E0),
              puzzles: englishColorPuzzles,
            ),
            _categoryCard(
              id: 'english_numbers',
              title: 'Zahlen',
              subtitle: 'one · two · three …',
              emoji: '🔢',
              color: const Color(0xFFBFE1FF),
              puzzles: englishNumberPuzzles,
            ),
            _categoryCard(
              id: 'english_animals',
              title: 'Tiere',
              subtitle: 'dog · cat · horse …',
              emoji: '🐾',
              color: const Color(0xFFCBEBC0),
              puzzles: englishAnimalPuzzles,
            ),
            _categoryCard(
              id: 'english_letters',
              title: 'Buchstaben',
              subtitle: 'A – apple · B – ball …',
              emoji: '🔤',
              color: const Color(0xFFFFD7B8),
              puzzles: englishLetterPuzzles,
            ),
          ],
        ),
      ),
    );
  }
}
