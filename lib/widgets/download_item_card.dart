import 'dart:io';
import 'package:flutter/material.dart';
import '../services/download_manager/download_task.dart';
import '../services/download_manager/download_status.dart';
import 'ascii_progress_bar.dart';
import 'ascii_status_spinner.dart';
import 'ascii_button.dart';

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
                    return AsciiStatusSpinner(
                      status: status,
                      speedNotifier: task.speed,
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
                  return ValueListenableBuilder(
                    valueListenable: task.progress,
                    builder: (context, progress, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AsciiProgressBar(
                            progressNotifier: task.progress,
                            speedNotifier: task.speed,
                            status: status,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontFamily: 'JetBrainsMono',
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (status == DownloadStatus.downloading)
                                ValueListenableBuilder<String>(
                                  valueListenable: task.speed,
                                  builder: (context, speed, child) {
                                    return ValueListenableBuilder<String>(
                                      valueListenable: task.eta,
                                      builder: (context, eta, child) {
                                        final speedText = speed.isNotEmpty ? ' ($speed)' : '';
                                        final etaText = eta.isNotEmpty ? ' • ETA: $eta' : '';
                                        return Text(
                                          'Downloading$speedText$etaText',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontFamily: 'JetBrainsMono',
                                              ),
                                        );
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
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
                      AsciiButton(
                        label: 'PAUSE',
                        color: colorScheme.secondary,
                        onPressed: onPause,
                      ),
                    if (status == DownloadStatus.paused && onResume != null) ...[
                      AsciiButton(
                        label: 'RESUME',
                        color: colorScheme.primary,
                        onPressed: onResume,
                      ),
                    ],
                    if ((status == DownloadStatus.downloading ||
                            status == DownloadStatus.paused ||
                            status == DownloadStatus.queued) &&
                        onCancel != null) ...[
                      const SizedBox(width: 8),
                      AsciiButton(
                        label: 'CANCEL',
                        color: colorScheme.outline,
                        onPressed: onCancel,
                      ),
                    ],
                    if ((status == DownloadStatus.failed ||
                            status == DownloadStatus.canceled) &&
                        onRemove != null) ...[
                      const SizedBox(width: 8),
                      AsciiButton(
                        label: 'REMOVE',
                        color: colorScheme.error,
                        onPressed: onRemove,
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

