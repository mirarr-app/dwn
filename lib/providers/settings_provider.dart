import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _downloadDirKey = 'download_directory';
  static const String _maxConcurrentKey = 'max_concurrent_downloads';

  ThemeMode _themeMode = ThemeMode.system;
  String _downloadDirectory = '';
  int _maxConcurrentDownloads = 2;

  ThemeMode get themeMode => _themeMode;
  String get downloadDirectory => _downloadDirectory;
  int get maxConcurrentDownloads => _maxConcurrentDownloads;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    // Load download directory
    final savedDir = prefs.getString(_downloadDirKey);
    if (savedDir != null && savedDir.isNotEmpty) {
      _downloadDirectory = savedDir;
    } else {
      _downloadDirectory = await _getDefaultDownloadDirectory();
      await prefs.setString(_downloadDirKey, _downloadDirectory);
    }

    // Load max concurrent downloads
    _maxConcurrentDownloads = prefs.getInt(_maxConcurrentKey) ?? 2;

    // Create download directory if it doesn't exist
    await _ensureDownloadDirectoryExists();

    notifyListeners();
  }

  Future<String> _getDefaultDownloadDirectory() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      return '${downloadsDir.path}/dwn';
    }
    // Fallback to home directory
    final homeDir = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    return '$homeDir/Downloads/dwn';
  }

  Future<void> _ensureDownloadDirectoryExists() async {
    final dir = Directory(_downloadDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setDownloadDirectory(String path) async {
    _downloadDirectory = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_downloadDirKey, path);
    await _ensureDownloadDirectoryExists();
    notifyListeners();
  }

  Future<void> setMaxConcurrentDownloads(int count) async {
    _maxConcurrentDownloads = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_maxConcurrentKey, count);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('download_history');
    notifyListeners();
  }
}

