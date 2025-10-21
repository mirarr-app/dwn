import 'package:flutter/material.dart';

class AppTheme {
  // Seed color for the app
  static const Color seedColor = Color(0xFF2196F3);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    typography: Typography.material2021(),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    navigationRailTheme: NavigationRailThemeData(
      elevation: 4,
      backgroundColor: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ).surface,
      selectedIconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ).primary,
      ),
      unselectedIconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ).onSurfaceVariant,
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    typography: Typography.material2021(),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    navigationRailTheme: NavigationRailThemeData(
      elevation: 4,
      backgroundColor: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ).surface,
      selectedIconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).primary,
      ),
      unselectedIconTheme: IconThemeData(
        color: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ).onSurfaceVariant,
      ),
    ),
  );
}

