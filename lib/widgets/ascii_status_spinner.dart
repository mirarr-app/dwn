import 'dart:math';
import 'package:flutter/material.dart';
import '../services/download_manager/download_status.dart';

class AsciiStatusSpinner extends StatefulWidget {
  final DownloadStatus status;
  final ValueNotifier<String>? speedNotifier;

  const AsciiStatusSpinner({
    super.key,
    required this.status,
    this.speedNotifier,
  });

  @override
  State<AsciiStatusSpinner> createState() => _AsciiStatusSpinnerState();
}

class _AsciiStatusSpinnerState extends State<AsciiStatusSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<String> _brailleFrames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    widget.speedNotifier?.addListener(_onSpeedChanged);
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant AsciiStatusSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedNotifier != widget.speedNotifier) {
      oldWidget.speedNotifier?.removeListener(_onSpeedChanged);
      widget.speedNotifier?.addListener(_onSpeedChanged);
    }
    _updateAnimationState();
  }

  @override
  void dispose() {
    widget.speedNotifier?.removeListener(_onSpeedChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSpeedChanged() {
    _updateAnimationState();
  }

  void _updateAnimationState() {
    if (!mounted) return;

    if (widget.status == DownloadStatus.canceled) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (widget.status == DownloadStatus.downloading &&
          widget.speedNotifier != null) {
        final newDuration = _getDurationForSpeed(widget.speedNotifier!.value);
        if (_controller.duration != newDuration) {
          _controller.duration = newDuration;
        }
      } else {
        const defaultDuration = Duration(milliseconds: 1500);
        if (_controller.duration != defaultDuration) {
          _controller.duration = defaultDuration;
        }
      }
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  Duration _getDurationForSpeed(String speedStr) {
    final speedBytes = _parseSpeed(speedStr);
    if (speedBytes <= 0) {
      return const Duration(milliseconds: 1500);
    }
    final speedMB = speedBytes / (1024.0 * 1024.0);
    // Faster speeds scale duration down to rotate quicker
    final durationMs =
        (1200 / (1.0 + speedMB * 2.0)).clamp(150.0, 1500.0).toInt();
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

  Color _getStatusColor(DownloadStatus status, ColorScheme colorScheme) {
    switch (status) {
      case DownloadStatus.completed:
        return colorScheme.primary;
      case DownloadStatus.downloading:
        return colorScheme.tertiary;
      case DownloadStatus.paused:
        return colorScheme.secondary;
      case DownloadStatus.failed:
        return colorScheme.error;
      case DownloadStatus.canceled:
        return colorScheme.outline;
      case DownloadStatus.queued:
        return colorScheme.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(widget.status, colorScheme);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        String badgeText = '';
        double opacity = 1.0;

        switch (widget.status) {
          case DownloadStatus.downloading:
            final frameIndex =
                (_controller.value * _brailleFrames.length).floor() %
                    _brailleFrames.length;
            final spinnerChar = _brailleFrames[frameIndex];
            badgeText = '$spinnerChar DOWNLOADING';
            break;

          case DownloadStatus.paused:
            badgeText = 'II PAUSED';
            // Slow pulse breath
            opacity = 0.35 +
                0.65 * (0.5 + 0.5 * sin(_controller.value * 2 * pi));
            break;

          case DownloadStatus.completed:
            badgeText = '✔ DONE';
            // High-frequency phosphor hum (green)
            final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
            final noise =
                (sin(time * 70.0) * cos(time * 29.0) * 100.0).abs() % 1.0;
            opacity = 0.82 + 0.18 * noise;
            break;

          case DownloadStatus.failed:
            badgeText = '⚡ ERR';
            // Loose terminal cable CRT flicker effect
            final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
            final noise =
                (sin(time * 90.0) * cos(time * 47.0) * 100.0).abs() % 1.0;
            // 18% chance of dropping to ultra-dim (flicker off)
            opacity = noise < 0.18 ? 0.15 : 1.0;
            break;

          case DownloadStatus.queued:
            badgeText = '… WAIT';
            opacity = 0.4 +
                0.4 * (0.5 + 0.5 * sin(_controller.value * 2 * pi));
            break;

          case DownloadStatus.canceled:
            badgeText = '✕ CANC';
            opacity = 0.7;
            break;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
            color: statusColor.withOpacity(0.06),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            badgeText,
            style: TextStyle(
              color: statusColor.withOpacity(opacity),
              fontFamily: 'JetBrainsMono',
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
}
