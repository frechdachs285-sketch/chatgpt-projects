import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final introSeen = await prefs.getBool('intro_seen') ?? false;
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
