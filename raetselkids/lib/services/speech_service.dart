import 'package:flutter_tts/flutter_tts.dart';

import 'music_service.dart';
import 'settings_service.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final SettingsService _settings = SettingsService();
  bool _ready = false;
  int _speechGeneration = 0;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setSpeechRate(0.56);
    await _tts.setPitch(1.24);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _ready = true;
  }

  Future<void> speak(String text, {String language = 'de-DE'}) async {
    if (!await _settings.isSpeechEnabled()) return;

    final generation = ++_speechGeneration;
    await _ensureReady();
    await _tts.stop();
    await MusicService.instance.duckForSpeech();

    try {
      await _tts.setLanguage(language);
      await _tts.speak(text);
    } finally {
      if (generation == _speechGeneration) {
        await MusicService.instance.restoreAfterSpeech();
      }
    }
  }

  Future<void> stop() async {
    ++_speechGeneration;
    await _tts.stop();
    await MusicService.instance.restoreAfterSpeech();
  }
}
