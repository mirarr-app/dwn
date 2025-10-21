import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import '../providers/settings_provider.dart';
import '../providers/download_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _selectDownloadDirectory(BuildContext context) async {
    final settingsProvider = context.read<SettingsProvider>();
    
    final result = await getDirectoryPath(
      confirmButtonText: 'Select',
      initialDirectory: settingsProvider.downloadDirectory,
    );

    if (result != null && context.mounted) {
      await settingsProvider.setDownloadDirectory(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download directory updated')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeModeText(settingsProvider.themeMode)),
                trailing: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Dark'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.auto_mode),
                      label: Text('System'),
                    ),
                  ],
                  selected: {settingsProvider.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    settingsProvider.setThemeMode(newSelection.first);
                  },
                ),
              );
            },
          ),
          const Divider(),

          // Download Settings Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Download Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Download Directory'),
                subtitle: Text(
                  settingsProvider.downloadDirectory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: FilledButton.icon(
                  onPressed: () => _selectDownloadDirectory(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Change'),
                ),
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return ListTile(
                leading: const Icon(Icons.speed_outlined),
                title: const Text('Max Concurrent Downloads'),
                subtitle: Text('${settingsProvider.maxConcurrentDownloads} downloads at a time'),
                trailing: SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: settingsProvider.maxConcurrentDownloads > 1
                            ? () {
                                final newValue =
                                    settingsProvider.maxConcurrentDownloads - 1;
                                settingsProvider.setMaxConcurrentDownloads(newValue);
                                context
                                    .read<DownloadProvider>()
                                    .setMaxConcurrentDownloads(newValue);
                              }
                            : null,
                      ),
                      Text(
                        '${settingsProvider.maxConcurrentDownloads}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: settingsProvider.maxConcurrentDownloads < 10
                            ? () {
                                final newValue =
                                    settingsProvider.maxConcurrentDownloads + 1;
                                settingsProvider.setMaxConcurrentDownloads(newValue);
                                context
                                    .read<DownloadProvider>()
                                    .setMaxConcurrentDownloads(newValue);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Data Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Clear Download History'),
            subtitle: const Text('Remove all completed downloads from history'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text(
                    'Are you sure you want to clear the download history? This will not delete the downloaded files.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<DownloadProvider>().clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                }
              }
            },
          ),

          const Divider(),

          // About Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('DWN Download Manager'),
            subtitle: Text('Version 0.1.0\nA Linux desktop download manager'),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}

