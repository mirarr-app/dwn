import 'dart:io';
import 'package:flutter/material.dart';
import '../services/download_manager/download_task.dart';
import '../services/download_manager/download_status.dart';

class DownloadItemCard extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRemove;

  const DownloadItemCard({
    super.key,
    required this.task,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRemove,
  });

  String _getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
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
        return colorScheme.surfaceContainerHighest;
    }
  }

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Icons.check_circle;
      case DownloadStatus.downloading:
        return Icons.downloading;
      case DownloadStatus.paused:
        return Icons.pause_circle;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.canceled:
        return Icons.cancel;
      case DownloadStatus.queued:
        return Icons.schedule;
    }
  }

  String _getStatusText(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.downloading:
        return 'Downloading';
      case DownloadStatus.paused:
        return 'Paused';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.canceled:
        return 'Canceled';
      case DownloadStatus.queued:
        return 'Queued';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filename = _getFileName(task.request.path);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filename and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    filename,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: task.status,
                  builder: (context, status, child) {
                    return Chip(
                      avatar: Icon(
                        _getStatusIcon(status),
                        size: 18,
                        color: _getStatusColor(status, colorScheme),
                      ),
                      label: Text(_getStatusText(status)),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // URL
            Text(
              task.request.url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Progress bar (for active downloads)
            ValueListenableBuilder(
              valueListenable: task.status,
              builder: (context, status, child) {
                if (status == DownloadStatus.downloading ||
                    status == DownloadStatus.paused ||
                    status == DownloadStatus.queued) {
                  return Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: task.progress,
                        builder: (context, progress, child) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${(progress * 100).toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  if (status == DownloadStatus.downloading)
                                    Text(
                                      'Downloading...',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Action buttons
            ValueListenableBuilder(
              valueListenable: task.status,
              builder: (context, status, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == DownloadStatus.downloading && onPause != null)
                      IconButton.filledTonal(
                        onPressed: onPause,
                        icon: const Icon(Icons.pause),
                        tooltip: 'Pause',
                      ),
                    if (status == DownloadStatus.paused && onResume != null) ...[
                      IconButton.filledTonal(
                        onPressed: onResume,
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Resume',
                      ),
                      const SizedBox(width: 8),
                    ],
                    if ((status == DownloadStatus.downloading ||
                            status == DownloadStatus.paused ||
                            status == DownloadStatus.queued) &&
                        onCancel != null)
                      IconButton.filledTonal(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close),
                        tooltip: 'Cancel',
                      ),
                    if ((status == DownloadStatus.failed ||
                            status == DownloadStatus.canceled) &&
                        onRemove != null) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete),
                        tooltip: 'Remove',
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

