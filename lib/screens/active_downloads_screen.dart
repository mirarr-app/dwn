import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_download_dialog.dart';
import '../widgets/download_item_card.dart';

class ActiveDownloadsScreen extends StatelessWidget {
  const ActiveDownloadsScreen({super.key});

  Future<void> _showAddDownloadDialog(BuildContext context) async {
    final urls = await showDialog<List<String>>(
      context: context,
      builder: (context) => const AddDownloadDialog(),
    );

    if (urls != null && urls.isNotEmpty && context.mounted) {
      final downloadProvider = context.read<DownloadProvider>();
      final settingsProvider = context.read<SettingsProvider>();

      try {
        if (urls.length == 1) {
          await downloadProvider.addDownload(
            urls.first,
            settingsProvider.downloadDirectory,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download added successfully')),
            );
          }
        } else {
          await downloadProvider.addBatchDownloads(
            urls,
            settingsProvider.downloadDirectory,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${urls.length} downloads added successfully')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding download: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Download',
            onPressed: () => _showAddDownloadDialog(context),
          ),
        ],
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, downloadProvider, child) {
          final activeDownloads = downloadProvider.activeDownloads;

          if (activeDownloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active downloads',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click the + button to add a download',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: activeDownloads.length,
            itemBuilder: (context, index) {
              final task = activeDownloads[index];
              return DownloadItemCard(
                task: task,
                onPause: () => downloadProvider.pauseDownload(task.request.url),
                onResume: () => downloadProvider.resumeDownload(task.request.url),
                onCancel: () => downloadProvider.cancelDownload(task.request.url),
                onRemove: () => downloadProvider.removeDownload(task.request.url),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDownloadDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Download'),
      ),
    );
  }
}

