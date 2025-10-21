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
          // Custom title bar
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
                    
                          const SizedBox(width: 8),
                          Text(
                            'DWN',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Window control buttons
                _WindowButton(
                  icon: Icons.minimize,
                  onPressed: () => windowManager.minimize(),
                ),
                _WindowButton(
                  icon: Icons.crop_square,
                  onPressed: () async {
                    bool isMaximized = await windowManager.isMaximized();
                    if (isMaximized) {
                      windowManager.unmaximize();
                    } else {
                      windowManager.maximize();
                    }
                  },
                ),
                _WindowButton(
                  icon: Icons.close,
                  onPressed: () => windowManager.close(),
                  isClose: true,
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
                
                // Main content area
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isClose
                    ? Colors.red
                    : Theme.of(context).colorScheme.surfaceContainerHighest)
                : Colors.transparent,
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered && widget.isClose
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
