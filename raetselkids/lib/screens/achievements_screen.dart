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

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF302E48))),
      );

  Widget _badgeCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool unlocked,
    bool special = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        gradient: unlocked
            ? LinearGradient(
                colors: special
                    ? const [Color(0xFFFFD76A), Color(0xFFFFF1B8)]
                    : const [Color(0xFFFFE7A1), Color(0xFFFFF8DD)],
              )
            : null,
        color: unlocked ? null : const Color(0xFFF0EFF3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: unlocked ? const Color(0x55D8A900) : const Color(0x16000000)),
        boxShadow: unlocked
            ? const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x16000000))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unlocked ? Colors.white.withValues(alpha: 0.88) : const Color(0xFFE2E0E5),
              shape: BoxShape.circle,
              border: unlocked ? Border.all(color: const Color(0x66E0B42D), width: 2) : null,
              boxShadow: unlocked ? const [BoxShadow(blurRadius: 7, color: Color(0x22000000))] : null,
            ),
            child: Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 27)),
          ),
          const SizedBox(width: 12),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: unlocked ? const Color(0xFF302E48) : const Color(0xFF77737F),
                        ),
                      ),
                    ),
                    if (unlocked) const Icon(Icons.check_circle_rounded, color: Color(0xFF44A36C), size: 23),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, height: 1.22)),
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
    final unlockedWorlds = _worlds.where((world) => (_best[world.id] ?? 0) >= 10).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF6),
      appBar: AppBar(title: const Text('Deine Erfolge 🏆'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: [
                  const RaetseliMascot(
                    message: 'Jeder Stern bringt dich einem neuen Abzeichen näher! ⭐',
                    mascotSize: 76,
                    mascotEmojiSize: 45,
                    messageFontSize: 15,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFE39A), Color(0xFFFFF3C8)]),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 38)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$_totalStars Sterne', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                              Text('$unlockedWorlds von ${_worlds.length} Welten-Abzeichen geschafft', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Sternen-Erfolge'),
                  _badgeCard(
                    emoji: '⭐', title: 'Sternenstarter',
                    subtitle: _totalStars >= 10 ? '10 Sterne gesammelt – geschafft!' : 'Noch ${10 - _totalStars} Sterne sammeln.',
                    unlocked: _totalStars >= 10,
                  ),
                  _badgeCard(
                    emoji: '🌟', title: 'Sternensammler',
                    subtitle: _totalStars >= 50 ? '50 Sterne gesammelt – geschafft!' : 'Noch ${50 - _totalStars} Sterne sammeln.',
                    unlocked: _totalStars >= 50,
                  ),
                  _badgeCard(
                    emoji: '✨', title: 'Rätseli-Freund',
                    subtitle: _totalStars >= 100 ? '100 Sterne gesammelt – wow!' : 'Noch ${100 - _totalStars} Sterne sammeln.',
                    unlocked: _totalStars >= 100,
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle('Welten-Abzeichen'),
                  ..._worlds.map((world) {
                    final value = _best[world.id] ?? 0;
                    final unlocked = value >= 10;
                    return _badgeCard(
                      emoji: world.emoji,
                      title: world.title,
                      subtitle: unlocked
                          ? '${world.worldName}: perfekte 10 Sterne – geschafft!'
                          : '${world.worldName}: $value/10 Sterne · noch ${10 - value} fehlen.',
                      unlocked: unlocked,
                    );
                  }),
                  const SizedBox(height: 12),
                  _sectionTitle('Das große Ziel'),
                  _badgeCard(
                    emoji: '🏆',
                    title: 'Rätselkönig',
                    subtitle: allPerfect ? 'Alle 7 Welten perfekt gemeistert!' : '$unlockedWorlds/7 Welten perfekt – sammle alle Abzeichen.',
                    unlocked: allPerfect,
                    special: true,
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
