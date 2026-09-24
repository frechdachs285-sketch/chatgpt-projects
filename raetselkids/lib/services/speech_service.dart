import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';

import 'settings_service.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SettingsService _settings = SettingsService();

  bool _ready = false;
  bool _moxManifestLoaded = false;
  Map<String, String> _moxClips = const {};
  int _playbackToken = 0;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setSpeechRate(0.56);
    await _tts.setPitch(1.24);
    await _tts.setVolume(1.0);
    _ready = true;
  }

  Future<void> _loadMoxManifest() async {
    if (_moxManifestLoaded) return;
    _moxManifestLoaded = true;

    try {
      final raw = await rootBundle.loadString('assets/audio/mox/manifest.json');
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      final clips = decoded['clips'];
      if (clips is! Map<String, dynamic>) return;

      _moxClips = clips.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } catch (_) {
      // Audio assets are optional during development. TTS remains the fallback.
      _moxClips = const {};
    }
  }

  Future<bool> _playMoxSegments(
    List<String> segments,
    int playbackToken,
  ) async {
    await _loadMoxManifest();
    if (_moxClips.isEmpty) return false;

    final filenames = <String>[];
    for (final segment in segments) {
      final filename = _moxClips[segment.trim()];
      if (filename == null) return false;
      filenames.add(filename);
    }

    for (final filename in filenames) {
      if (playbackToken != _playbackToken) return true;
      await _audioPlayer.play(AssetSource('audio/mox/$filename'));
      await _audioPlayer.onPlayerComplete.first;
    }
    return true;
  }

  Future<void> speak(String text, {String language = 'de-DE'}) async {
    if (!await _settings.isSpeechEnabled()) return;

    final playbackToken = ++_playbackToken;
    await _audioPlayer.stop();
    await _ensureReady();
    await _tts.stop();

    if (playbackToken != _playbackToken) return;
    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  Future<void> speakSegments(
    List<String> segments, {
    String language = 'de-DE',
  }) async {
    if (segments.isEmpty || !await _settings.isSpeechEnabled()) return;

    final playbackToken = ++_playbackToken;
    await _tts.stop();
    await _audioPlayer.stop();

    if (language.startsWith('de') &&
        await _playMoxSegments(segments, playbackToken)) {
      return;
    }

    if (playbackToken != _playbackToken) return;
    await _ensureReady();
    await _tts.setLanguage(language);
    await _tts.speak(segments.join('. '));
  }

  Future<void> stop() async {
    _playbackToken++;
    await _audioPlayer.stop();
    await _tts.stop();
  }
}
