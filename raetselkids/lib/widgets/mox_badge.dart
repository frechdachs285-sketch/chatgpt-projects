import 'package:flutter/material.dart';

class MoxBadge extends StatelessWidget {
  final double size;
  final bool showLabel;
  final String? message;

  const MoxBadge({
    super.key,
    this.size = 48,
    this.showLabel = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final image = Semantics(
      label: 'Mox, der Tüftler-Begleiter',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          'assets/branding/app_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );

    if (message != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          image,
          const SizedBox(width: 7),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3F6666),
            ),
          ),
        ],
      );
    }

    if (!showLabel) return image;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        const SizedBox(height: 2),
        const Text(
          'Mox',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xFF3F6666),
            height: 1,
          ),
        ),
      ],
    );
  }
}
