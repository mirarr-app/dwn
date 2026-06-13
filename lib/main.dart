import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/download_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/active_downloads_screen.dart';
import 'screens/completed_downloads_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'services/theme_sevice.dart';
import 'widgets/ascii_frame.dart';
import 'widgets/add_download_dialog.dart';
import 'widgets/ascii_button.dart';
import 'services/download_manager/download_status.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure window manager
  await windowManager.ensureInitialized();
  
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Color _seedColor = Colors.blue;
  Timer? _themeTimer;

  @override
  void initState() {
    super.initState();
    // Initial theme color fetch
    _updateThemeColor();
    
    // Start periodic timer to check theme every 2 seconds
    _themeTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _updateThemeColor(),
    );
  }

  @override
  void dispose() {
    _themeTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateThemeColor() async {
    final newColor = await ThemeService.getOmarchyThemeColor();
    if (mounted && newColor != _seedColor) {
      setState(() {
        _seedColor = newColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'DWN',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(_seedColor),
            darkTheme: AppTheme.darkTheme(_seedColor),
            themeMode: settingsProvider.themeMode,
            home: const MainLayout(),
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with WindowListener {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ActiveDownloadsScreen(),
    CompletedDownloadsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        final shortcuts = [
          {'desc': 'Show Shortcuts Helper', 'keys': 'Ctrl + K'},
          {'desc': 'Add New Download', 'keys': 'Ctrl + N'},
          {'desc': 'Active Downloads Screen', 'keys': 'Ctrl + 1'},
          {'desc': 'Completed Downloads Screen', 'keys': 'Ctrl + 2'},
          {'desc': 'Settings Screen', 'keys': 'Ctrl + 3'},
          {'desc': 'Pause All Downloads', 'keys': 'Ctrl + P'},
          {'desc': 'Resume All Downloads', 'keys': 'Ctrl + R'},
          {'desc': 'Clear Download History', 'keys': 'Ctrl + D'},
          {'desc': 'Close Application', 'keys': 'Ctrl + Q'},
        ];

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: SizedBox(
            width: 550,
            height: 480,
            child: AsciiFrame(
              title: 'KEYBOARD SHORTCUTS',
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GLOBAL SHORTCUTS',
                      style: textTheme.titleMedium?.copyWith(
                        fontFamily: 'JetBrainsMono',
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: shortcuts.length,
                        itemBuilder: (context, index) {
                          final item = shortcuts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['desc']!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontFamily: 'JetBrainsMono',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    border: Border.all(
                                      color: scheme.outline,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['keys']!,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'JetBrainsMono',
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AsciiButton(
                        label: 'CLOSE',
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _triggerAddDownload(BuildContext context) async {
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

  void _pauseAllDownloads(BuildContext context) {
    final provider = context.read<DownloadProvider>();
    final downloading = provider.activeDownloads
        .where((t) => t.status.value == DownloadStatus.downloading)
        .toList();
    if (downloading.isEmpty) return;

    for (final task in downloading) {
      provider.pauseDownload(task.request.url);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Paused ${downloading.length} download(s)')),
    );
  }

  void _resumeAllDownloads(BuildContext context) {
    final provider = context.read<DownloadProvider>();
    final paused = provider.activeDownloads
        .where((t) => t.status.value == DownloadStatus.paused)
        .toList();
    if (paused.isEmpty) return;

    for (final task in paused) {
      provider.resumeDownload(task.request.url);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Resumed ${paused.length} download(s)')),
    );
  }

  Future<void> _clearHistory(BuildContext context) async {
    final provider = context.read<DownloadProvider>();
    if (provider.history.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear the download history? This will not delete the downloaded files.',
        ),
        actions: [
          AsciiButton(
            label: 'CANCEL',
            color: Theme.of(context).colorScheme.outline,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AsciiButton(
            label: 'CLEAR',
            color: Theme.of(context).colorScheme.error,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await provider.clearHistory();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          _showShortcutsDialog(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          _triggerAddDownload(context);
        },
        const SingleActivator(LogicalKeyboardKey.digit1, control: true): () {
          setState(() {
            _selectedIndex = 0;
          });
        },
        const SingleActivator(LogicalKeyboardKey.digit2, control: true): () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        const SingleActivator(LogicalKeyboardKey.digit3, control: true): () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          _pauseAllDownloads(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () {
          _resumeAllDownloads(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () {
          _clearHistory(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyQ, control: true): () {
          windowManager.close();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              // Custom title bar (ASCII-inspired)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Draggable area
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          windowManager.startDragging();
                        },
                        onDoubleTap: () async {
                          bool isMaximized = await windowManager.isMaximized();
                          if (isMaximized) {
                            windowManager.unmaximize();
                          } else {
                            windowManager.maximize();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                '[ DWN ]',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontFamily: 'JetBrainsMono',
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Window control buttons (ASCII labels)
                    _AsciiWindowButton(
                      label: '__',
                      semanticLabel: 'Minimize',
                      onPressed: () => windowManager.minimize(),
                    ),
                    _AsciiWindowButton(
                      label: '[ ]',
                      semanticLabel: 'Maximize',
                      onPressed: () async {
                        bool isMaximized = await windowManager.isMaximized();
                        if (isMaximized) {
                          windowManager.unmaximize();
                        } else {
                          windowManager.maximize();
                        }
                      },
                    ),
                    _AsciiWindowButton(
                      label: 'x',
                      semanticLabel: 'Close',
                      isClose: true,
                      onPressed: () => windowManager.close(),
                    ),
                  ],
                ),
              ),
              // Main content
              Expanded(
                child: Row(
                  children: [
                    // Navigation Rail
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Icon(
                          Icons.download,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.downloading_outlined),
                          selectedIcon: Icon(Icons.downloading),
                          label: Text('Active'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.done_all_outlined),
                          selectedIcon: Icon(Icons.done_all),
                          label: Text('Completed'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    
                    // Main content area wrapped in ASCII frame
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AsciiFrame(
                          title: _selectedIndex == 0
                              ? 'ACTIVE DOWNLOADS'
                              : _selectedIndex == 1
                                  ? 'COMPLETED DOWNLOADS'
                                  : 'SETTINGS',
                          child: _screens[_selectedIndex],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AsciiWindowButton extends StatefulWidget {
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool isClose;

  const _AsciiWindowButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_AsciiWindowButton> createState() => _AsciiWindowButtonState();
}

class _AsciiWindowButtonState extends State<_AsciiWindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isClose ? Colors.red : scheme.surfaceContainerHighest)
                : Colors.transparent,
            border: Border(
              left: BorderSide(color: scheme.outlineVariant, width: 1),
            ),
          ),
          child: Text(
            widget.label,
            semanticsLabel: widget.semanticLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'JetBrainsMono',
                  color: _isHovered && widget.isClose ? Colors.white : scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
