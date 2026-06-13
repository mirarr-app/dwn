import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _downloadDirKey = 'download_directory';
  static const String _maxConcurrentKey = 'max_concurrent_downloads';
  static const String _aria2MaxConnectionsKey = 'aria2_max_connections';
  static const String _aria2SplitKey = 'aria2_split';
  static const String _aria2MinSplitSizeKey = 'aria2_min_split_size';
  static const String _aria2FileAllocationKey = 'aria2_file_allocation';

  ThemeMode _themeMode = ThemeMode.system;
  String _downloadDirectory = '';
  int _maxConcurrentDownloads = 2;
  int _aria2MaxConnections = 16;
  int _aria2Split = 16;
  String _aria2MinSplitSize = '1M';
  String _aria2FileAllocation = 'falloc';

  ThemeMode get themeMode => _themeMode;
  String get downloadDirectory => _downloadDirectory;
  int get maxConcurrentDownloads => _maxConcurrentDownloads;
  int get aria2MaxConnections => _aria2MaxConnections;
  int get aria2Split => _aria2Split;
  String get aria2MinSplitSize => _aria2MinSplitSize;
  String get aria2FileAllocation => _aria2FileAllocation;

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

    // Load aria2c settings
    _aria2MaxConnections = prefs.getInt(_aria2MaxConnectionsKey) ?? 16;
    _aria2Split = prefs.getInt(_aria2SplitKey) ?? 16;
    _aria2MinSplitSize = prefs.getString(_aria2MinSplitSizeKey) ?? '1M';
    _aria2FileAllocation = prefs.getString(_aria2FileAllocationKey) ?? 'falloc';

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

  Future<void> setAria2MaxConnections(int count) async {
    _aria2MaxConnections = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_aria2MaxConnectionsKey, count);
    notifyListeners();
  }

  Future<void> setAria2Split(int count) async {
    _aria2Split = count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_aria2SplitKey, count);
    notifyListeners();
  }

  Future<void> setAria2MinSplitSize(String size) async {
    _aria2MinSplitSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aria2MinSplitSizeKey, size);
    notifyListeners();
  }

  Future<void> setAria2FileAllocation(String method) async {
    _aria2FileAllocation = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aria2FileAllocationKey, method);
    notifyListeners();
  }
}

