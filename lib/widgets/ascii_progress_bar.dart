import 'package:flutter/material.dart';
import '../services/download_manager/download_status.dart';

class AsciiProgressBar extends StatefulWidget {
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> speedNotifier;
  final DownloadStatus status;

  const AsciiProgressBar({
    super.key,
    required this.progressNotifier,
    required this.speedNotifier,
    required this.status,
  });

  @override
  State<AsciiProgressBar> createState() => _AsciiProgressBarState();
}

class _AsciiProgressBarState extends State<AsciiProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDurationForSpeed(widget.speedNotifier.value),
    );
    widget.speedNotifier.addListener(_onSpeedChanged);
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant AsciiProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedNotifier != widget.speedNotifier) {
      oldWidget.speedNotifier.removeListener(_onSpeedChanged);
      widget.speedNotifier.addListener(_onSpeedChanged);
    }
    _updateAnimationState();
  }

  @override
  void dispose() {
    widget.speedNotifier.removeListener(_onSpeedChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSpeedChanged() {
    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (!mounted) return;
    if (widget.status == DownloadStatus.downloading) {
      final newDuration = _getDurationForSpeed(widget.speedNotifier.value);
      if (_controller.duration != newDuration) {
        _controller.duration = newDuration;
      }
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  Duration _getDurationForSpeed(String speedStr) {
    final speedBytes = _parseSpeed(speedStr);
    if (speedBytes <= 0) {
      return const Duration(milliseconds: 3000);
    }
    final speedMB = speedBytes / (1024.0 * 1024.0);
    // 1 MB/s -> ~1.0s cycle. 10 MB/s -> ~250ms cycle.
    final durationMs =
        (2500 / (1.0 + speedMB * 1.5)).clamp(150.0, 3000.0).toInt();
    return Duration(milliseconds: durationMs);
  }

  double _parseSpeed(String speedStr) {
    if (speedStr.isEmpty) return 0.0;
    final cleanStr = speedStr.replaceAll('DL:', '').trim();
    final match = RegExp(r'^([\d.]+)\s*([a-zA-Z/]*)$').firstMatch(cleanStr);
    if (match == null) return 0.0;
    final value = double.tryParse(match.group(1) ?? '0') ?? 0.0;
    final unit = (match.group(2) ?? '').toLowerCase();

    if (unit.contains('g')) {
      return value * 1024 * 1024 * 1024;
    } else if (unit.contains('m')) {
      return value * 1024 * 1024;
    } else if (unit.contains('k')) {
      return value * 1024;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'JetBrainsMono',
            ) ??
        const TextStyle(fontFamily: 'JetBrainsMono');

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = textStyle.fontSize ?? 12.0;
        final charWidth = fontSize * 0.62; // Monospace character width aspect ratio

        // Calculate segment count dynamically to fill width. 
        // Brackets '[' and ']' take 2 character slots.
        int segmentsCount = (constraints.maxWidth / charWidth).floor() - 2;
        if (segmentsCount < 10) segmentsCount = 10;
        if (segmentsCount > 120) segmentsCount = 120;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = widget.progressNotifier.value.clamp(0.0, 1.0);
            final filledSegments = (progress * segmentsCount).floor();

            final List<InlineSpan> spans = [];

            // Prefix bracket
            spans.add(TextSpan(
              text: '[',
              style: textStyle.copyWith(color: colorScheme.outline),
            ));

            final baseColor = widget.status == DownloadStatus.paused
                ? colorScheme.secondary
                : (widget.status == DownloadStatus.queued
                    ? colorScheme.outlineVariant
                    : colorScheme.tertiary);

            final highlightColor = widget.status == DownloadStatus.downloading
                ? Colors.white
                : baseColor;

            for (int i = 0; i < segmentsCount; i++) {
              String char = '░';
              Color charColor = colorScheme.onSurface.withOpacity(0.15);

              if (i < filledSegments) {
                char = '█';
                double intensity = 0.0;
                if (widget.status == DownloadStatus.downloading) {
                  // The sweep shimmer sweeps across the active area
                  final sweepPos =
                      -3.0 + _controller.value * (filledSegments + 6.0);
                  final distance = (i - sweepPos).abs();
                  intensity = (1.0 - (distance / 3.0)).clamp(0.0, 1.0);
                }
                charColor =
                    Color.lerp(baseColor, highlightColor, intensity * 0.8)!;
              } else if (i == filledSegments) {
                if (widget.status == DownloadStatus.downloading) {
                  // Blinking cursor
                  final isBlinkOn = (_controller.value * 4).toInt() % 2 == 0;
                  char = isBlinkOn ? '█' : '_';

                  final sweepPos =
                      -3.0 + _controller.value * (filledSegments + 6.0);
                  final distance = (i - sweepPos).abs();
                  final intensity = (1.0 - (distance / 3.0)).clamp(0.0, 1.0);
                  charColor =
                      Color.lerp(baseColor, highlightColor, intensity * 0.8)!;
                } else if (widget.status == DownloadStatus.paused) {
                  char = '▒';
                  charColor = baseColor;
                } else {
                  char = '░';
                  charColor = colorScheme.onSurface.withOpacity(0.15);
                }
              } else {
                char = '░';
                charColor = colorScheme.onSurface.withOpacity(0.15);
              }

              spans.add(TextSpan(
                text: char,
                style: textStyle.copyWith(
                  color: charColor,
                  fontWeight: FontWeight.bold,
                ),
              ));
            }

            // Suffix bracket
            spans.add(TextSpan(
              text: ']',
              style: textStyle.copyWith(color: colorScheme.outline),
            ));

            return Text.rich(
              TextSpan(children: spans),
              maxLines: 1,
              overflow: TextOverflow.clip,
            );
          },
        );
      },
    );
  }
}
