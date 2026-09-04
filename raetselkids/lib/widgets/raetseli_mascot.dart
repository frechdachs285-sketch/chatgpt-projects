import 'package:flutter/material.dart';

class RaetseliMascot extends StatelessWidget {
  final String message;
  final bool celebrate;
  final VoidCallback? onSpeak;

  const RaetseliMascot({
    super.key,
    required this.message,
    this.celebrate = false,
    this.onSpeak,
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
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: celebrate
                  ? const Color(0xFFFFE082)
                  : const Color(0xFFD8D4FF),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 14,
                  offset: Offset(0, 5),
                  color: Color(0x18000000),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              celebrate ? '🤩' : '🦊',
              style: const TextStyle(fontSize: 44),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 14,
                  offset: Offset(0, 5),
                  color: Color(0x12000000),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                if (onSpeak != null)
                  IconButton.filledTonal(
                    tooltip: 'Vorlesen',
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up_rounded),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
