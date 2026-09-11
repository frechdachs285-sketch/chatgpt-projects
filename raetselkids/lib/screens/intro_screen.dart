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
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  int _page = 0;

  static const _pages = <_IntroPage>[
    _IntroPage(
      emoji: '🦊',
      title: 'Hallo bei RätselKids!',
      mascotMessage: 'Komm, wir rätseln zusammen! 😊',
      text: 'Ich bin Rätseli und rätsle mit dir. Zusammen schaffen wir das!',
      speech: 'Hallo bei RätselKids! Ich bin Rätseli und rätsle mit dir. Zusammen schaffen wir das!',
    ),
    _IntroPage(
      emoji: '👆',
      title: 'Einfach antippen',
      mascotMessage: 'Du entscheidest! 👆',
      text: 'Hör gut zu und tippe auf die Antwort, die du richtig findest.',
      speech: 'Hör gut zu und tippe auf die Antwort, die du richtig findest.',
    ),
    _IntroPage(
      emoji: '🔊',
      title: 'Ich lese dir vor',
      mascotMessage: 'Ich helfe dir beim Zuhören! 🔊',
      text: 'Du musst noch nicht alles lesen können. Mit der Sprachtaste hörst du die Aufgabe noch einmal.',
      speech: 'Du musst noch nicht alles lesen können. Mit der Sprachtaste hörst du die Aufgabe noch einmal.',
    ),
    _IntroPage(
      emoji: '⭐',
      title: 'Sammle Sterne!',
      mascotMessage: 'Fürs Rätseln gibt es Sterne! ⭐',
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

    await _prefs.setBool('intro_seen', true);
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
      backgroundColor: const Color(0xFFFFFCF5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 42,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFE8FF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${_page + 1} / ${_pages.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF625D80),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      RaetseliMascot(
                        message: page.mascotMessage,
                        mascotSize: 100,
                        mascotEmojiSize: 60,
                        messageFontSize: 17,
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: 108,
                        height: 108,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0B8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Text(page.emoji, style: const TextStyle(fontSize: 58)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF302E48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0x22A68DFF)),
                        ),
                        child: Text(
                          page.text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF514F61),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 18),
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
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF91DEBC),
                            foregroundColor: const Color(0xFF302E48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
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
          },
        ),
      ),
    );
  }
}

class _IntroPage {
  final String emoji;
  final String title;
  final String mascotMessage;
  final String text;
  final String speech;

  const _IntroPage({
    required this.emoji,
    required this.title,
    required this.mascotMessage,
    required this.text,
    required this.speech,
  });
}
