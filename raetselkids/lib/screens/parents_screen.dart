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
        title: const Text('Fortschritt löschen?'),
        content: const Text('Alle Sterne, Bestleistungen und Abzeichen werden zurückgesetzt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elternbereich 🔒')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Einstellungen',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.record_voice_over_rounded),
                    title: const Text('Sprachausgabe'),
                    subtitle: const Text('Rätseli liest Aufgaben und Rückmeldungen vor.'),
                    value: _speech,
                    onChanged: (value) async {
                      await _settings.setSpeechEnabled(value);
                      if (!mounted) return;
                      setState(() => _speech = value);
                    },
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.music_note_rounded),
                    title: const Text('Sounds & Haptik'),
                    subtitle: const Text('Kurze Rückmeldungen bei Antworten.'),
                    value: _sound,
                    onChanged: (value) async {
                      await _settings.setSoundEnabled(value);
                      if (!mounted) return;
                      setState(() => _sound = value);
                    },
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Daten',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text(
                      'Fortschritt zurücksetzen',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'RätselKids speichert den Spielstand nur lokal auf diesem Gerät.',
                  style: TextStyle(fontSize: 15, height: 1.4),
                ),
              ],
            ),
    );
  }
}
