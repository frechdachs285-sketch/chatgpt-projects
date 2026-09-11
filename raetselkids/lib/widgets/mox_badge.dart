import 'package:flutter/material.dart';

class MoxBadge extends StatefulWidget {
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
  State<MoxBadge> createState() => _MoxBadgeState();
}

class _MoxBadgeState extends State<MoxBadge> {
  static const _tapMessages = <String>[
    'Mox tüftelt mit!',
    'Knifflig? Wir schaffen das!',
    'Mox hat die Denkbrille auf!',
    'Schau ganz genau hin!',
    'Tüftelmodus an!',
  ];

  late int _tapIndex;

  @override
  void initState() {
    super.initState();
    _tapIndex = _indexForMessage(widget.message);
  }

  int _indexForMessage(String? message) {
    final index = _tapMessages.indexOf(message ?? '');
    return index >= 0 ? index : 0;
  }

  String? get _shownMessage {
    if (widget.message == null) return null;
    if (widget.onTap != null) return widget.message;
    return _tapMessages[_tapIndex % _tapMessages.length];
  }

  @override
  void didUpdateWidget(covariant MoxBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _tapIndex = _indexForMessage(widget.message);
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    if (widget.message == null) return;
    setState(() {
      _tapIndex = (_tapIndex + 1) % _tapMessages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.onTap != null || widget.message != null;
    final shownMessage = _shownMessage;

    final image = Semantics(
      label: 'Mox, der Tüftler-Begleiter',
      button: isInteractive,
      child: Container(
        width: widget.size,
        height: widget.size,
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
    if (shownMessage != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          image,
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              shownMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3F6666),
              ),
            ),
          ),
        ],
      );
    } else if (widget.showLabel) {
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

    if (!isInteractive) return content;

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(widget.size),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: content,
      ),
    );
  }
}
