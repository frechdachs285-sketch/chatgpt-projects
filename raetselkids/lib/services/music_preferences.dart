import 'package:shared_preferences/shared_preferences.dart';

class MusicPreferences {
  static const _trackKey = 'music_track';
  static const _randomKey = 'music_random_enabled';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<String> getMusicTrack() async {
    return await _prefs.getString(_trackKey) ?? 'rainbow';
  }

  Future<void> setMusicTrack(String trackId) async {
    await _prefs.setString(_trackKey, trackId);
  }

  Future<bool> isMusicRandomEnabled() async {
    return await _prefs.getBool(_randomKey) ?? false;
  }

  Future<void> setMusicRandomEnabled(bool enabled) async {
    await _prefs.setBool(_randomKey, enabled);
  }
}
