import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/speech_service.dart';
import '../widgets/raetseli_mascot.dart';
import 'daily_matching_screen.dart';

class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  final SpeechService _speech = SpeechService();
  int _nextNumber = 1;
  bool _finished = false;
  bool _showMatching = false;
  late final _DailyMotif _motif;

  static const _motifs = <_DailyMotif>[
    _DailyMotif(name: 'Stern', emoji: '⭐', points: [Offset(0.50, 0.10), Offset(0.61, 0.36), Offset(0.89, 0.38), Offset(0.68, 0.56), Offset(0.76, 0.86), Offset(0.50, 0.69), Offset(0.24, 0.86), Offset(0.32, 0.56), Offset(0.11, 0.38), Offset(0.39, 0.36)]),
    _DailyMotif(name: 'Haus', emoji: '🏠', points: [Offset(0.20, 0.48), Offset(0.50, 0.18), Offset(0.80, 0.48), Offset(0.80, 0.82), Offset(0.60, 0.82), Offset(0.60, 0.60), Offset(0.40, 0.60), Offset(0.40, 0.82), Offset(0.20, 0.82), Offset(0.20, 0.48)]),
    _DailyMotif(name: 'Fisch', emoji: '🐟', points: [Offset(0.18, 0.50), Offset(0.34, 0.31), Offset(0.60, 0.24), Offset(0.79, 0.40), Offset(0.92, 0.29), Offset(0.88, 0.50), Offset(0.92, 0.71), Offset(0.79, 0.60), Offset(0.60, 0.76), Offset(0.34, 0.69)]),
    _DailyMotif(name: 'Rakete', emoji: '🚀', points: [Offset(0.50, 0.10), Offset(0.67, 0.29), Offset(0.71, 0.58), Offset(0.84, 0.73), Offset(0.64, 0.69), Offset(0.57, 0.88), Offset(0.50, 0.73), Offset(0.43, 0.88), Offset(0.36, 0.69), Offset(0.16, 0.73), Offset(0.29, 0.58), Offset(0.33, 0.29)]),
    _DailyMotif(name: 'Herz', emoji: '❤️', points: [Offset(0.50, 0.82), Offset(0.28, 0.64), Offset(0.16, 0.43), Offset(0.22, 0.25), Offset(0.39, 0.20), Offset(0.50, 0.35), Offset(0.61, 0.20), Offset(0.78, 0.25), Offset(0.84, 0.43), Offset(0.72, 0.64)]),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final dayKey = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
    _showMatching = dayKey.isOdd;
    _motif = _motifs[(dayKey ~/ 2) % _motifs.length];
    if (!_showMatching) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _speech.speak('Tagesrätsel! Tippe die Zahlen der Reihe nach an. Beginne mit der Eins.'));
    }
  }

  @override
  void dispose() { _speech.stop(); super.dispose(); }

  Future<void> _tapPoint(int number) async {
    if (_finished || number != _nextNumber) { if (!_finished) HapticFeedback.selectionClick(); return; }
    HapticFeedback.lightImpact();
    if (number == _motif.points.length) {
      setState(() { _nextNumber++; _finished = true; });
      await _speech.speak('Juhuuu! Du hast alle Zahlen verbunden. Es ist ein ${_motif.name}!');
    } else { setState(() => _nextNumber++); }
  }

  @override
  Widget build(BuildContext context) {
    if (_showMatching) return const DailyMatchingScreen();
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF6),
      appBar: AppBar(title: const Text('🎁 Tagesrätsel'), centerTitle: true),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
        child: Column(children: [
          RaetseliMascot(message: _finished ? 'Geschafft! ${_motif.emoji} Aus den Punkten ist ein ${_motif.name} geworden!' : 'Verbinde die Zahlen von 1 bis ${_motif.points.length}. Was entsteht wohl? 🤔', mascotSize: 72, mascotEmojiSize: 43, messageFontSize: 15),
          const SizedBox(height: 14),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            final size = math.min(constraints.maxWidth, constraints.maxHeight);
            return Center(child: SizedBox.square(dimension: size, child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _ConnectPainter(points: _motif.points, connectedCount: _nextNumber - 1, finished: _finished))),
              ..._motif.points.asMap().entries.map((entry) {
                final number = entry.key + 1; final point = entry.value; final done = number < _nextNumber;
                return Positioned(left: point.dx * size - 23, top: point.dy * size - 23, child: GestureDetector(onTap: () => _tapPoint(number), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: done ? const Color(0xFFFFD966) : Colors.white, shape: BoxShape.circle, border: Border.all(color: done ? const Color(0xFFE0A900) : const Color(0xFF6E68A8), width: 3), boxShadow: const [BoxShadow(blurRadius: 7, offset: Offset(0, 3), color: Color(0x22000000))]), child: Text('$number', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF302E48))))));
              }),
              if (_finished) Center(child: Text(_motif.emoji, style: const TextStyle(fontSize: 105))),
            ])));
          })),
          const SizedBox(height: 10),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), decoration: BoxDecoration(color: const Color(0xFFFFF0B8), borderRadius: BorderRadius.circular(20)), child: Text(_finished ? '🎉 Tagesrätsel geschafft!' : 'Als Nächstes: $_nextNumber', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          if (_finished) ...[const SizedBox(height: 10), SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Zurück zu RätselKids ⭐', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))))],
        ]),
      )),
    );
  }
}

class _DailyMotif { final String name; final String emoji; final List<Offset> points; const _DailyMotif({required this.name, required this.emoji, required this.points}); }

class _ConnectPainter extends CustomPainter {
  final List<Offset> points; final int connectedCount; final bool finished;
  const _ConnectPainter({required this.points, required this.connectedCount, required this.finished});
  @override
  void paint(Canvas canvas, Size size) {
    if (connectedCount < 2) return;
    final paint = Paint()..color = const Color(0xFF6E68A8)..strokeWidth = 6..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final path = Path(); final first = points.first; path.moveTo(first.dx * size.width, first.dy * size.height);
    for (var i = 1; i < connectedCount && i < points.length; i++) { path.lineTo(points[i].dx * size.width, points[i].dy * size.height); }
    if (finished) path.lineTo(first.dx * size.width, first.dy * size.height);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _ConnectPainter oldDelegate) => oldDelegate.connectedCount != connectedCount || oldDelegate.finished != finished || oldDelegate.points != points;
}
