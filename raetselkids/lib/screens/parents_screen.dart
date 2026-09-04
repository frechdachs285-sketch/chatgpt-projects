import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';

class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final SettingsService _settings = SettingsService();
  final ProgressService _progress = ProgressService();
  bool _speech = true;
  bool _sound = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final speech = await _settings.isSpeechEnabled();
    final sound = await _settings.isSoundEnabled();
    if (!mounted) return;
    setState(() {
      _speech = speech;
      _sound = sound;
      _loading = false;
    });
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 38),
        title: const Text('Fortschritt wirklich löschen?'),
        content: const Text(
          'Alle Sterne, Bestleistungen und Abzeichen werden auf diesem Gerät zurückgesetzt.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja, löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _progress.resetProgress();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Spielfortschritt wurde zurückgesetzt.')),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF6D5BD0)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _settingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        secondary: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EEFF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: const Color(0xFF6D5BD0)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: const Text('Elternbereich'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEDE8FF), Color(0xFFFFF2D8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🦊', style: TextStyle(fontSize: 48)),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Für die Großen 🔒',
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2B2B3A),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Hier stellst du ein, wie Rätseli spricht und reagiert. Der Spielstand bleibt nur auf diesem Gerät.',
                                style: TextStyle(fontSize: 15, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _sectionTitle('Hören & Fühlen', Icons.tune_rounded),
                  const SizedBox(height: 12),
                  _settingCard(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Rätseli spricht',
                    subtitle: 'Aufgaben und Rückmeldungen werden vorgelesen.',
                    value: _speech,
                    onChanged: (value) async {
                      await _settings.setSpeechEnabled(value);
                      if (!mounted) return;
                      setState(() => _speech = value);
                    },
                  ),
                  _settingCard(
                    icon: Icons.vibration_rounded,
                    title: 'Sounds & Haptik',
                    subtitle: 'Kurze Ton- und Vibrationsrückmeldungen bei Antworten.',
                    value: _sound,
                    onChanged: (value) async {
                      await _settings.setSoundEnabled(value);
                      if (!mounted) return;
                      setState(() => _sound = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Spielstand', Icons.star_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8EF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: Color(0xFF3D8B5B)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Keine Cloud, kein Konto: Sterne und Bestleistungen werden nur lokal gespeichert.',
                            style: TextStyle(fontSize: 15, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 58,
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB23A48),
                        side: const BorderSide(color: Color(0xFFE7AAB2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text(
                        'Fortschritt zurücksetzen',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
