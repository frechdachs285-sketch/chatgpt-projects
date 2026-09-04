import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _starsKey = 'total_stars';
  static const _completedPrefix = 'completed_';
  static const _bestPrefix = 'best_stars_';
  static const _dailyCompletedKey = 'daily_completed_date';

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> getTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_starsKey) ?? 0;
  }

  Future<void> addStars(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_starsKey) ?? 0;
    await prefs.setInt(_starsKey, current + amount);
  }

  Future<bool> isDailyCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_dailyCompletedKey) == _todayKey();
  }

  Future<bool> completeDailyPuzzle() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (prefs.getString(_dailyCompletedKey) == today) return false;
    final current = prefs.getInt(_starsKey) ?? 0;
    await prefs.setInt(_starsKey, current + 1);
    await prefs.setString(_dailyCompletedKey, today);
    return true;
  }

  Future<int> getCompletedCount(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_completedPrefix$categoryId') ?? 0;
  }

  Future<void> saveCompletedCount(String categoryId, int completed) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_completedPrefix$categoryId';
    final current = prefs.getInt(key) ?? 0;
    if (completed > current) {
      await prefs.setInt(key, completed);
    }
  }

  Future<int> getBestStars(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_bestPrefix$categoryId') ?? 0;
  }

  Future<bool> saveBestStars(String categoryId, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_bestPrefix$categoryId';
    final current = prefs.getInt(key) ?? 0;
    if (stars > current) {
      await prefs.setInt(key, stars);
      return true;
    }
    return false;
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
          (key) => key == _starsKey ||
              key == _dailyCompletedKey ||
              key.startsWith(_completedPrefix) ||
              key.startsWith(_bestPrefix),
        );
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
