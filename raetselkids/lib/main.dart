import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RaetselKidsApp());
}

class RaetselKidsApp extends StatelessWidget {
  const RaetselKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RätselKids',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
