import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

import 'music_preferences.dart';
import 'settings_service.dart';

class MusicTrack {
  final String id;
  final String label;
  final String emoji;
  final String assetPath;

  const MusicTrack({
    required this.id,
    required this.label,
    required this.emoji,
    required this.assetPath,
  });
}

class MusicService {
  MusicService._();

  static final MusicService instance = MusicService._();

  static const tracks = <MusicTrack>[
    MusicTrack(
      id: 'rainbow',
      label: 'Regenbogen',
      emoji: '🌈',
      assetPath: 'audio/music/rainbow.mp3',
    ),
    MusicTrack(
      id: 'adventure',
      label: 'Abenteuer',
      emoji: '🐾',
      assetPath: 'audio/music/adventure.mp3',
    ),
    MusicTrack(
      id: 'star_dance',
      label: 'Sternentanz',
      emoji: '⭐',
      assetPath: 'audio/music/star_dance.mp3',
    ),
    MusicTrack(
      id: 'magic_forest',
      label: 'Zauberwald',
      emoji: '🌳',
      assetPath: 'audio/music/magic_forest.mp3',
    ),
    MusicTrack(
      id: 'dream_cloud',
      label: 'Traumwolke',
      emoji: '☁️',
      assetPath: 'audio/music/dream_cloud.mp3',
    ),
  ];

  final AudioPlayer _player = AudioPlayer();
  final SettingsService _settings = SettingsService();
  final MusicPreferences _musicPreferences = MusicPreferences();
  final Random _random = Random();

  MusicTrack? _currentTrack;
  double _normalVolume = 0.24;

  MusicTrack? get currentTrack => _currentTrack;

  Future<void> initialize() async {
    await _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> startSelected() async {
    if (!await _settings.isMusicEnabled()) {
      await stop();
      return;
    }

    final randomEnabled = await _musicPreferences.isMusicRandomEnabled();
    final selectedId = await _musicPreferences.getMusicTrack();
    final track = randomEnabled
        ? tracks[_random.nextInt(tracks.length)]
        : tracks.firstWhere(
            (item) => item.id == selectedId,
            orElse: () => tracks.first,
          );

    await playTrack(track);
  }

  Future<void> playTrack(MusicTrack track) async {
    if (!await _settings.isMusicEnabled()) return;
    _currentTrack = track;
    await _player.stop();
    await _player.setVolume(_normalVolume);
    await _player.play(AssetSource(track.assetPath));
  }

  Future<void> stop() async {
    _currentTrack = null;
    await _player.stop();
  }

  Future<void> setEnabled(bool enabled) async {
    await _settings.setMusicEnabled(enabled);
    if (enabled) {
      await startSelected();
    } else {
      await stop();
    }
  }

  Future<void> selectTrack(String trackId) async {
    await _musicPreferences.setMusicTrack(trackId);
    final track = tracks.firstWhere(
      (item) => item.id == trackId,
      orElse: () => tracks.first,
    );
    await playTrack(track);
  }

  Future<void> setRandomEnabled(bool enabled) async {
    await _musicPreferences.setMusicRandomEnabled(enabled);
    if (enabled) await startSelected();
  }

  Future<void> duckForSpeech() async {
    await _player.setVolume(0.06);
  }

  Future<void> restoreAfterSpeech() async {
    if (_currentTrack == null) return;
    await _player.setVolume(_normalVolume);
  }

  Future<void> setNormalVolume(double volume) async {
    _normalVolume = volume.clamp(0.0, 1.0);
    if (_currentTrack != null) {
      await _player.setVolume(_normalVolume);
    }
  }

  Future<void> dispose() => _player.dispose();
}
