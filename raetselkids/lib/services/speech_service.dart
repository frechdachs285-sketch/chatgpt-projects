import 'dart:async';
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
  Completer<void>? _cancelPlayback;

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

  Completer<void> _startPlaybackSession() {
    if (_cancelPlayback != null && !_cancelPlayback!.isCompleted) {
      _cancelPlayback!.complete();
    }
    _cancelPlayback = Completer<void>();
    return _cancelPlayback!;
  }

  Duration _pauseAfterSegment(int index, int total) {
    if (index >= total - 1) return Duration.zero;

    // Segment 0 is the question. Afterwards label and answer alternate:
    // question -> Antwort 1 -> value -> Antwort 2 -> value -> Antwort 3 -> value.
    if (index == 0) return const Duration(milliseconds: 450);
    if (index.isOdd) return const Duration(milliseconds: 220);
    return const Duration(milliseconds: 600);
  }

  Future<bool> _playMoxSegments(
    List<String> segments,
    int playbackToken,
    Completer<void> cancellation,
  ) async {
    await _loadMoxManifest();
    if (_moxClips.isEmpty) return false;

    final filenames = <String>[];
    for (final segment in segments) {
      final filename = _moxClips[segment.trim()];
      if (filename == null) return false;
      filenames.add(filename);
    }

    for (var index = 0; index < filenames.length; index++) {
      if (playbackToken != _playbackToken || cancellation.isCompleted) {
        return true;
      }

      final completed = _audioPlayer.onPlayerComplete.first;
      await _audioPlayer.play(AssetSource('audio/mox/${filenames[index]}'));

      await Future.any<void>([
        completed,
        cancellation.future,
      ]);

      if (playbackToken != _playbackToken || cancellation.isCompleted) {
        return true;
      }

      final pause = _pauseAfterSegment(index, filenames.length);
      if (pause > Duration.zero) {
        await Future.any<void>([
          Future<void>.delayed(pause),
          cancellation.future,
        ]);
      }
    }
    return true;
  }

  Future<void> speak(String text, {String language = 'de-DE'}) async {
    if (!await _settings.isSpeechEnabled()) return;

    final playbackToken = ++_playbackToken;
    final cancellation = _startPlaybackSession();
    await _audioPlayer.stop();
    await _ensureReady();
    await _tts.stop();

    if (playbackToken != _playbackToken || cancellation.isCompleted) return;
    await _tts.setLanguage(language);
    await _tts.speak(text);
  }

  Future<void> speakSegments(
    List<String> segments, {
    String language = 'de-DE',
  }) async {
    if (segments.isEmpty || !await _settings.isSpeechEnabled()) return;

    final playbackToken = ++_playbackToken;
    final cancellation = _startPlaybackSession();
    await _tts.stop();
    await _audioPlayer.stop();

    if (language.startsWith('de') &&
        await _playMoxSegments(segments, playbackToken, cancellation)) {
      return;
    }

    if (playbackToken != _playbackToken || cancellation.isCompleted) return;
    await _ensureReady();
    await _tts.setLanguage(language);
    await _tts.speak(segments.join('. '));
  }

  Future<void> stop() async {
    _playbackToken++;
    if (_cancelPlayback != null && !_cancelPlayback!.isCompleted) {
      _cancelPlayback!.complete();
    }
    await _audioPlayer.stop();
    await _tts.stop();
  }
}
