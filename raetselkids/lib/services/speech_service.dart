import 'package:flutter_tts/flutter_tts.dart';
import 'settings_service.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final SettingsService _settings = SettingsService();
  bool _ready = false;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setLanguage('de-DE');
    await _tts.setSpeechRate(0.56);
    await _tts.setPitch(1.24);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  Future<void> speak(String text) async {
    if (!await _settings.isSpeechEnabled()) return;
    await _ensureReady();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
