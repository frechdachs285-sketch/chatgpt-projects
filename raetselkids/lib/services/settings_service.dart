import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _speechKey = 'speech_enabled';
  static const _soundKey = 'sound_enabled';

  Future<bool> isSpeechEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_speechKey) ?? true;
  }

  Future<void> setSpeechEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_speechKey, enabled);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }
}
