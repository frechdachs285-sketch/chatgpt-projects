import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var introSeen = false;

  try {
    // Older RätselKids versions stored progress with the legacy
    // SharedPreferences API. SharedPreferencesAsync uses DataStore on Android
    // by default, so migrate the old values before reading the new store.
    final legacyPrefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: legacyPrefs,
      sharedPreferencesAsyncOptions: const SharedPreferencesOptions(),
      migrationCompletedKey: 'raetselkids_legacy_migration_v1',
    );

    final prefs = SharedPreferencesAsync();
    introSeen = await prefs.getBool('intro_seen') ?? false;
  } catch (_) {
    // If local preferences cannot be read, the app should still start.
    // Falling back to the introduction is the safest child-friendly default.
    introSeen = false;
  }

  runApp(RaetselKidsApp(introSeen: introSeen));
}

class RaetselKidsApp extends StatelessWidget {
  final bool introSeen;

  const RaetselKidsApp({super.key, required this.introSeen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RätselKids',
      theme: AppTheme.light,
      home: introSeen ? const HomeScreen() : const IntroScreen(),
    );
  }
}
