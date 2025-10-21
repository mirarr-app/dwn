import 'package:flutter/material.dart';

class AppTheme {
  // Light theme
  static ThemeData lightTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      typography: Typography.material2021(platform: TargetPlatform.linux).copyWith(
        black: Typography.material2021(platform: TargetPlatform.linux).black.copyWith(
          displayLarge: Typography.material2021(platform: TargetPlatform.linux).black.displayLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          displayMedium: Typography.material2021(platform: TargetPlatform.linux).black.displayMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          displaySmall: Typography.material2021(platform: TargetPlatform.linux).black.displaySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineLarge: Typography.material2021(platform: TargetPlatform.linux).black.headlineLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineMedium: Typography.material2021(platform: TargetPlatform.linux).black.headlineMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineSmall: Typography.material2021(platform: TargetPlatform.linux).black.headlineSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          titleLarge: Typography.material2021(platform: TargetPlatform.linux).black.titleLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          titleMedium: Typography.material2021(platform: TargetPlatform.linux).black.titleMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          titleSmall: Typography.material2021(platform: TargetPlatform.linux).black.titleSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyLarge: Typography.material2021(platform: TargetPlatform.linux).black.bodyLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyMedium: Typography.material2021(platform: TargetPlatform.linux).black.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          bodySmall: Typography.material2021(platform: TargetPlatform.linux).black.bodySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          labelLarge: Typography.material2021(platform: TargetPlatform.linux).black.labelLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          labelMedium: Typography.material2021(platform: TargetPlatform.linux).black.labelMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          labelSmall: Typography.material2021(platform: TargetPlatform.linux).black.labelSmall?.copyWith(fontFamily: 'JetBrainsMono'),
        ),
        white: Typography.material2021(platform: TargetPlatform.linux).white.copyWith(
          displayLarge: Typography.material2021(platform: TargetPlatform.linux).white.displayLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          displayMedium: Typography.material2021(platform: TargetPlatform.linux).white.displayMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          displaySmall: Typography.material2021(platform: TargetPlatform.linux).white.displaySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineLarge: Typography.material2021(platform: TargetPlatform.linux).white.headlineLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineMedium: Typography.material2021(platform: TargetPlatform.linux).white.headlineMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineSmall: Typography.material2021(platform: TargetPlatform.linux).white.headlineSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          titleLarge: Typography.material2021(platform: TargetPlatform.linux).white.titleLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          titleMedium: Typography.material2021(platform: TargetPlatform.linux).white.titleMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          titleSmall: Typography.material2021(platform: TargetPlatform.linux).white.titleSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyLarge: Typography.material2021(platform: TargetPlatform.linux).white.bodyLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyMedium: Typography.material2021(platform: TargetPlatform.linux).white.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          bodySmall: Typography.material2021(platform: TargetPlatform.linux).white.bodySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          labelLarge: Typography.material2021(platform: TargetPlatform.linux).white.labelLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          labelMedium: Typography.material2021(platform: TargetPlatform.linux).white.labelMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          labelSmall: Typography.material2021(platform: TargetPlatform.linux).white.labelSmall?.copyWith(fontFamily: 'JetBrainsMono'),
        ),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.linux).black.apply(fontFamily: 'JetBrainsMono'),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: colorScheme.surface,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.surfaceContainerHighest,
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.surfaceContainerHighest,
        selectedLabelTextStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
        unselectedLabelTextStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(colorScheme.primary),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineWidth: MaterialStateProperty.all(1),
        trackOutlineColor: MaterialStateProperty.all(colorScheme.outlineVariant),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      typography: Typography.material2021(platform: TargetPlatform.linux).copyWith(
        black: Typography.material2021(platform: TargetPlatform.linux).black.copyWith(
          displayLarge: Typography.material2021(platform: TargetPlatform.linux).black.displayLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          displayMedium: Typography.material2021(platform: TargetPlatform.linux).black.displayMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          displaySmall: Typography.material2021(platform: TargetPlatform.linux).black.displaySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineLarge: Typography.material2021(platform: TargetPlatform.linux).black.headlineLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineMedium: Typography.material2021(platform: TargetPlatform.linux).black.headlineMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineSmall: Typography.material2021(platform: TargetPlatform.linux).black.headlineSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          titleLarge: Typography.material2021(platform: TargetPlatform.linux).black.titleLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          titleMedium: Typography.material2021(platform: TargetPlatform.linux).black.titleMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          titleSmall: Typography.material2021(platform: TargetPlatform.linux).black.titleSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyLarge: Typography.material2021(platform: TargetPlatform.linux).black.bodyLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyMedium: Typography.material2021(platform: TargetPlatform.linux).black.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          bodySmall: Typography.material2021(platform: TargetPlatform.linux).black.bodySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          labelLarge: Typography.material2021(platform: TargetPlatform.linux).black.labelLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          labelMedium: Typography.material2021(platform: TargetPlatform.linux).black.labelMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          labelSmall: Typography.material2021(platform: TargetPlatform.linux).black.labelSmall?.copyWith(fontFamily: 'JetBrainsMono'),
        ),
        white: Typography.material2021(platform: TargetPlatform.linux).white.copyWith(
          displayLarge: Typography.material2021(platform: TargetPlatform.linux).white.displayLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          displayMedium: Typography.material2021(platform: TargetPlatform.linux).white.displayMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          displaySmall: Typography.material2021(platform: TargetPlatform.linux).white.displaySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineLarge: Typography.material2021(platform: TargetPlatform.linux).white.headlineLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineMedium: Typography.material2021(platform: TargetPlatform.linux).white.headlineMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          headlineSmall: Typography.material2021(platform: TargetPlatform.linux).white.headlineSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          titleLarge: Typography.material2021(platform: TargetPlatform.linux).white.titleLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          titleMedium: Typography.material2021(platform: TargetPlatform.linux).white.titleMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          titleSmall: Typography.material2021(platform: TargetPlatform.linux).white.titleSmall?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyLarge: Typography.material2021(platform: TargetPlatform.linux).white.bodyLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          bodyMedium: Typography.material2021(platform: TargetPlatform.linux).white.bodyMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          bodySmall: Typography.material2021(platform: TargetPlatform.linux).white.bodySmall?.copyWith(fontFamily: 'JetBrainsMono'),
          labelLarge: Typography.material2021(platform: TargetPlatform.linux).white.labelLarge?.copyWith(fontFamily: 'JetBrainsMono'),
          labelMedium: Typography.material2021(platform: TargetPlatform.linux).white.labelMedium?.copyWith(fontFamily: 'JetBrainsMono'),
          labelSmall: Typography.material2021(platform: TargetPlatform.linux).white.labelSmall?.copyWith(fontFamily: 'JetBrainsMono'),
        ),
      ),
      textTheme: Typography.material2021(platform: TargetPlatform.linux).white.apply(fontFamily: 'JetBrainsMono'),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: colorScheme.surface,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        tileColor: colorScheme.surface,
        selectedTileColor: colorScheme.surfaceContainerHighest,
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.surfaceContainerHighest,
        selectedLabelTextStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
        unselectedLabelTextStyle: const TextStyle(fontFamily: 'JetBrainsMono'),
        selectedIconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(colorScheme.primary),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineWidth: MaterialStateProperty.all(1),
        trackOutlineColor: MaterialStateProperty.all(colorScheme.outlineVariant),
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colorScheme.primary, width: 1),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      buttonTheme: const ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
    );
  }
}

