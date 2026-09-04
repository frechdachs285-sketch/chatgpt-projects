import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _starsKey = 'total_stars';
  static const _completedPrefix = 'completed_';
  static const _bestPrefix = 'best_stars_';

  Future<int> getTotalStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_starsKey) ?? 0;
  }

  Future<void> addStars(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_starsKey) ?? 0;
    await prefs.setInt(_starsKey, current + amount);
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
              key.startsWith(_completedPrefix) ||
              key.startsWith(_bestPrefix),
        );
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
