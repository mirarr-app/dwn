import 'package:flutter/material.dart';

class AsciiFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? title;

  const AsciiFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outlineVariant;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
        // Corner glyphs for ASCII vibe
        Positioned(
          top: 0,
          left: 0,
          child: _corner(context, '┌'),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _corner(context, '┐'),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: _corner(context, '└'),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _corner(context, '┘'),
        ),
        if (title != null && title!.isNotEmpty)
          Positioned(
            top: -1,
            left: 12,
            child: Container(
              color: scheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '[ ${title!} ]',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontFamily: 'JetBrainsMono',
                      color: scheme.onSurface,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _corner(BuildContext context, String glyph) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      glyph,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontFamily: 'JetBrainsMono',
            color: scheme.onSurfaceVariant,
          ),
    );
  }
}


