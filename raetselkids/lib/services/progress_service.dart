import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _starsKey = 'total_stars';
  static const _completedPrefix = 'completed_';
  static const _bestPrefix = 'best_stars_';
  static const _dailyCompletedKey = 'daily_completed_date';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> getTotalStars() async {
    return await _prefs.getInt(_starsKey) ?? 0;
  }

  Future<void> addStars(int amount) async {
    final current = await _prefs.getInt(_starsKey) ?? 0;
    await _prefs.setInt(_starsKey, current + amount);
  }

  Future<bool> isDailyCompletedToday() async {
    return await _prefs.getString(_dailyCompletedKey) == _todayKey();
  }

  Future<bool> completeDailyPuzzle() async {
    final today = _todayKey();
    if (await _prefs.getString(_dailyCompletedKey) == today) return false;
    final current = await _prefs.getInt(_starsKey) ?? 0;
    await _prefs.setInt(_starsKey, current + 1);
    await _prefs.setString(_dailyCompletedKey, today);
    return true;
  }

  Future<int> getCompletedCount(String categoryId) async {
    return await _prefs.getInt('$_completedPrefix$categoryId') ?? 0;
  }

  Future<void> saveCompletedCount(String categoryId, int completed) async {
    final key = '$_completedPrefix$categoryId';
    final current = await _prefs.getInt(key) ?? 0;
    if (completed > current) {
      await _prefs.setInt(key, completed);
    }
  }

  Future<int> getBestStars(String categoryId) async {
    return await _prefs.getInt('$_bestPrefix$categoryId') ?? 0;
  }

  Future<bool> saveBestStars(String categoryId, int stars) async {
    final key = '$_bestPrefix$categoryId';
    final current = await _prefs.getInt(key) ?? 0;
    if (stars > current) {
      await _prefs.setInt(key, stars);
      return true;
    }
    return false;
  }

  Future<void> resetProgress() async {
    final keys = await _prefs.getKeys();
    final progressKeys = keys.where(
      (key) => key == _starsKey ||
          key == _dailyCompletedKey ||
          key.startsWith(_completedPrefix) ||
          key.startsWith(_bestPrefix),
    );
    for (final key in progressKeys) {
      await _prefs.remove(key);
    }
  }
}
