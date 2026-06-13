import 'package:flutter/material.dart';

class AsciiButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool compact;

  const AsciiButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.compact = false,
  });

  @override
  State<AsciiButton> createState() => _AsciiButtonState();
}

class _AsciiButtonState extends State<AsciiButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = widget.onPressed != null;

    final baseColor = widget.color ?? scheme.primary;
    final hoverBgColor = baseColor.withOpacity(0.08);
    final displayColor = isEnabled
        ? (_isHovered ? baseColor : baseColor.withOpacity(0.85))
        : scheme.outline.withOpacity(0.4);

    final padding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

    return MouseRegion(
      onEnter: isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled
                  ? (_isHovered ? baseColor : baseColor.withOpacity(0.35))
                  : scheme.outline.withOpacity(0.18),
              width: 1,
            ),
            color: isEnabled && _isHovered ? hoverBgColor : Colors.transparent,
          ),
          padding: padding,
          child: Text(
            widget.label,
            style: TextStyle(
              color: displayColor,
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              fontSize: widget.compact ? 11 : 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
