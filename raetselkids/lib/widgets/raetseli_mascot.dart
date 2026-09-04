import 'package:flutter/material.dart';

class RaetseliMascot extends StatelessWidget {
  final String message;
  final bool celebrate;
  final VoidCallback? onSpeak;
  final double mascotSize;
  final double mascotEmojiSize;
  final double messageFontSize;

  const RaetseliMascot({
    super.key,
    required this.message,
    this.celebrate = false,
    this.onSpeak,
    this.mascotSize = 76,
    this.mascotEmojiSize = 44,
    this.messageFontSize = 17,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TweenAnimationBuilder<double>(
          key: ValueKey('$message-$celebrate'),
          tween: Tween(begin: 0.82, end: 1.0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.elasticOut,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: Container(
            width: mascotSize,
            height: mascotSize,
            decoration: BoxDecoration(
              color: celebrate ? const Color(0xFFFFE082) : const Color(0xFFD8D4FF),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [BoxShadow(blurRadius: 16, offset: Offset(0, 6), color: Color(0x22000000))],
            ),
            alignment: Alignment.center,
            child: Text(celebrate ? '🤩' : '🦊', style: TextStyle(fontSize: mascotEmojiSize)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x22A68DFF)),
              boxShadow: const [BoxShadow(blurRadius: 14, offset: Offset(0, 5), color: Color(0x16000000))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: messageFontSize, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                ),
                if (onSpeak != null)
                  IconButton.filledTonal(tooltip: 'Vorlesen', onPressed: onSpeak, icon: const Icon(Icons.volume_up_rounded)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
