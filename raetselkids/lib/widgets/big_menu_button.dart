import 'package:flutter/material.dart';

class BigMenuButton extends StatelessWidget {
  final String label;
  final String emoji;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final double height;
  final double fontSize;
  final double emojiSize;

  const BigMenuButton({
    super.key,
    required this.label,
    required this.emoji,
    required this.onPressed,
    this.backgroundColor,
    this.height = 82,
    this.fontSize = 24,
    this.emojiSize = 34,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? Theme.of(context).colorScheme.primaryContainer;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF29293A),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: emojiSize)),
            const SizedBox(width: 14),
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
