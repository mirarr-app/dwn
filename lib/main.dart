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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  fontFamily: 'monospace',
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
                  fontFamily: 'monospace',
                  color: _isHovered && widget.isClose ? Colors.white : scheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }
}
