import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../widgets/raetseli_mascot.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final ProgressService _progress = ProgressService();
  int _totalStars = 0;
  bool _loading = true;
  final Map<String, int> _best = {};

  static const _worlds = <_WorldAchievement>[
    _WorldAchievement('numbers', '🔢', 'Zahlenprofi', 'Zahlen'),
    _WorldAchievement('animals', '🐾', 'Tierdetektiv', 'Tiere'),
    _WorldAchievement('colors', '🎨', 'Farbenmeister', 'Farben'),
    _WorldAchievement('missing', '🔍', 'Musterknacker', 'Was fehlt?'),
    _WorldAchievement('shapes', '🔷', 'Formenfinder', 'Formen'),
    _WorldAchievement('opposites', '↔️', 'Gegensatz-Genie', 'Gegensätze'),
    _WorldAchievement('letters', '🔤', 'Buchstabenstar', 'Buchstaben'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final totalStars = await _progress.getTotalStars();
    final values = <String, int>{};
    for (final world in _worlds) {
      values[world.id] = await _progress.getBestStars(world.id);
    }
    if (!mounted) return;
    setState(() {
      _totalStars = totalStars;
      _best
        ..clear()
        ..addAll(values);
      _loading = false;
    });
  }

  Widget _sectionTitle(String emoji, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF302E48),
              ),
            ),
          ],
        ),
      );

  Widget _badgeCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool unlocked,
    bool special = false,
  }) {
    final unlockedColors = special
        ? const [Color(0xFFFFD76A), Color(0xFFFFF3BD)]
        : const [Color(0xFFFFE7A1), Color(0xFFFFF8DD)];

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        gradient: unlocked ? LinearGradient(colors: unlockedColors) : null,
        color: unlocked ? null : const Color(0xFFF2F0F5),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: unlocked ? const Color(0x44D8A900) : const Color(0x12000000),
          width: 2,
        ),
        boxShadow: unlocked
            ? const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 5),
                  color: Color(0x15000000),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFFE4E1E8),
              shape: BoxShape.circle,
              border: unlocked
                  ? Border.all(color: const Color(0x55E0B42D), width: 2)
                  : null,
            ),
            child: Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 31)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: unlocked
                              ? const Color(0xFF302E48)
                              : const Color(0xFF77737F),
                        ),
                      ),
                    ),
                    if (unlocked)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF44A36C),
                        size: 25,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, height: 1.22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPerfect = _worlds.every((world) => (_best[world.id] ?? 0) >= 10);
    final unlockedWorlds =
        _worlds.where((world) => (_best[world.id] ?? 0) >= 10).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF5),
      appBar: AppBar(title: const Text('Deine Erfolge 🏆')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  const Positioned(
                    top: 34,
                    right: 14,
                    child: Opacity(
                      opacity: .38,
                      child: Text('✨', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const Positioned(
                    top: 190,
                    left: 8,
                    child: Opacity(
                      opacity: .28,
                      child: Text('⭐', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                    children: [
                      const RaetseliMascot(
                        message: 'Schau mal, was du schon geschafft hast! ⭐',
                        mascotSize: 76,
                        mascotEmojiSize: 45,
                        messageFontSize: 15,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE39A), Color(0xFFFFF3C8)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 13,
                              offset: Offset(0, 5),
                              color: Color(0x15000000),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Color(0xCCFFFFFF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text('⭐', style: TextStyle(fontSize: 38)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_totalStars Sterne',
                                    style: const TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF302E48),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$unlockedWorlds von ${_worlds.length} Welten-Abzeichen',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF514F61),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle('🌟', 'Sternen-Erfolge'),
                      _badgeCard(
                        emoji: '⭐',
                        title: 'Sternenstarter',
                        subtitle: _totalStars >= 10
                            ? 'Geschafft: 10 Sterne!'
                            : '${10 - _totalStars} Sterne fehlen noch.',
                        unlocked: _totalStars >= 10,
                      ),
                      _badgeCard(
                        emoji: '🌟',
                        title: 'Sternensammler',
                        subtitle: _totalStars >= 50
                            ? 'Geschafft: 50 Sterne!'
                            : '${50 - _totalStars} Sterne fehlen noch.',
                        unlocked: _totalStars >= 50,
                      ),
                      _badgeCard(
                        emoji: '✨',
                        title: 'Rätseli-Freund',
                        subtitle: _totalStars >= 100
                            ? 'Wow, 100 Sterne!'
                            : '${100 - _totalStars} Sterne fehlen noch.',
                        unlocked: _totalStars >= 100,
                      ),
                      const SizedBox(height: 10),
                      _sectionTitle('🏅', 'Welten-Abzeichen'),
                      ..._worlds.map((world) {
                        final value = _best[world.id] ?? 0;
                        final unlocked = value >= 10;
                        return _badgeCard(
                          emoji: world.emoji,
                          title: world.title,
                          subtitle: unlocked
                              ? '${world.worldName}: geschafft! ⭐'
                              : '${world.worldName}: $value von 10 ⭐',
                          unlocked: unlocked,
                        );
                      }),
                      const SizedBox(height: 10),
                      _sectionTitle('🏆', 'Das große Ziel'),
                      _badgeCard(
                        emoji: '🏆',
                        title: 'Rätselkönig',
                        subtitle: allPerfect
                            ? 'Alle 7 Welten geschafft!'
                            : '$unlockedWorlds von 7 Welten geschafft.',
                        unlocked: allPerfect,
                        special: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _WorldAchievement {
  final String id;
  final String emoji;
  final String title;
  final String worldName;

  const _WorldAchievement(this.id, this.emoji, this.title, this.worldName);
}
