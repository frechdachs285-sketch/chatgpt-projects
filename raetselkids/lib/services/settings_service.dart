import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _speechKey = 'speech_enabled';
  static const _soundKey = 'sound_enabled';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  Future<bool> isSpeechEnabled() async {
    return await _prefs.getBool(_speechKey) ?? true;
  }

  Future<void> setSpeechEnabled(bool enabled) async {
    await _prefs.setBool(_speechKey, enabled);
  }

  Future<bool> isSoundEnabled() async {
    return await _prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundKey, enabled);
  }
}
