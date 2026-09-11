import 'package:flutter/material.dart';

class MoxBadge extends StatelessWidget {
  final double size;
  final bool showLabel;
  final String? message;
  final VoidCallback? onTap;

  const MoxBadge({
    super.key,
    this.size = 48,
    this.showLabel = false,
    this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = Semantics(
      label: 'Mox, der Tüftler-Begleiter',
      button: onTap != null,
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

    Widget content;
    if (message != null) {
      content = Row(
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
    } else if (showLabel) {
      content = Column(
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
    } else {
      content = image;
    }

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: content,
      ),
    );
  }
}
