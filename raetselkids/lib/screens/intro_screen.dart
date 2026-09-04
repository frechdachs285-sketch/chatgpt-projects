import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/speech_service.dart';
import '../widgets/raetseli_mascot.dart';
import 'home_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final SpeechService _speech = SpeechService();
  int _page = 0;

  static const _pages = <_IntroPage>[
    _IntroPage(
      emoji: '🦊',
      title: 'Hallo bei RätselKids!',
      text: 'Ich bin Rätseli und rätsle mit dir. Zusammen schaffen wir das!',
      speech: 'Hallo bei RätselKids! Ich bin Rätseli und rätsle mit dir. Zusammen schaffen wir das!',
    ),
    _IntroPage(
      emoji: '👆',
      title: 'Einfach antippen',
      text: 'Hör gut zu und tippe auf die Antwort, die du richtig findest.',
      speech: 'Hör gut zu und tippe auf die Antwort, die du richtig findest.',
    ),
    _IntroPage(
      emoji: '🔊',
      title: 'Ich lese dir vor',
      text: 'Du musst noch nicht alles lesen können. Mit der Sprachtaste hörst du die Aufgabe noch einmal.',
      speech: 'Du musst noch nicht alles lesen können. Mit der Sprachtaste hörst du die Aufgabe noch einmal.',
    ),
    _IntroPage(
      emoji: '⭐',
      title: 'Sammle Sterne!',
      text: 'Für gelöste Rätsel bekommst du Sterne und kannst tolle Abzeichen schaffen.',
      speech: 'Für gelöste Rätsel bekommst du Sterne und kannst tolle Abzeichen schaffen. Los gehts!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  Future<void> _speak() => _speech.speak(_pages[_page].speech);

  Future<void> _next() async {
    if (_page < _pages.length - 1) {
      setState(() => _page++);
      await _speak();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_seen', true);
    await _speech.stop();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    final last = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${_page + 1} / ${_pages.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF77737F),
                  ),
                ),
              ),
              const Spacer(),
              RaetseliMascot(
                message: page.text,
                mascotSize: 112,
                mascotEmojiSize: 66,
                messageFontSize: 18,
              ),
              const SizedBox(height: 28),
              Text(page.emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 12),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF302E48),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                page.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF514F61),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    width: index == _page ? 24 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _page
                          ? const Color(0xFF6E68A8)
                          : const Color(0xFFD8D4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF91DEBC),
                    foregroundColor: const Color(0xFF302E48),
                  ),
                  child: Text(
                    last ? '🚀 Los geht’s!' : 'Weiter ➜',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroPage {
  final String emoji;
  final String title;
  final String text;
  final String speech;

  const _IntroPage({
    required this.emoji,
    required this.title,
    required this.text,
    required this.speech,
  });
}
