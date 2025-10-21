import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/download_manager/downloader.dart';
import '../services/download_manager/download_task.dart';
import '../services/download_manager/download_status.dart';

class DownloadHistoryItem {
  final String url;
  final String filename;
  final String path;
  final DateTime completedAt;
  final int fileSize;

  DownloadHistoryItem({
    required this.url,
    required this.filename,
    required this.path,
    required this.completedAt,
    required this.fileSize,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'filename': filename,
        'path': path,
        'completedAt': completedAt.toIso8601String(),
        'fileSize': fileSize,
      };

  factory DownloadHistoryItem.fromJson(Map<String, dynamic> json) {
    return DownloadHistoryItem(
      url: json['url'] as String,
      filename: json['filename'] as String,
      path: json['path'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      fileSize: json['fileSize'] as int,
    );
  }
}

class DownloadProvider with ChangeNotifier {
  final DownloadManager _downloadManager = DownloadManager();
  final List<DownloadHistoryItem> _history = [];
  final Map<String, StreamSubscription> _statusListeners = {};

  List<DownloadTask> get activeDownloads {
    return _downloadManager
        .getAllDownloads()
        .where((task) => !task.status.value.isCompleted)
        .toList();
  }

  List<DownloadTask> get completedDownloads {
    return _downloadManager
        .getAllDownloads()
        .where((task) => task.status.value == DownloadStatus.completed)
        .toList();
  }

  List<DownloadHistoryItem> get history => List.unmodifiable(_history);

  DownloadProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('download_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history.clear();
      _history.addAll(
        decoded.map((item) => DownloadHistoryItem.fromJson(item)).toList(),
      );
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_history.map((item) => item.toJson()).toList());
    await prefs.setString('download_history', historyJson);
  }

  Future<void> addDownload(String url, String downloadDir) async {
    try {
      final task = await _downloadManager.addDownload(url, downloadDir);
      if (task != null) {
        _setupTaskListener(task);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding download: $e');
      }
      rethrow;
    }
  }

  Future<void> addBatchDownloads(List<String> urls, String downloadDir) async {
    try {
      await _downloadManager.addBatchDownloads(urls, downloadDir);
      
      // Set up listeners for all newly added downloads
      for (final url in urls) {
        final task = _downloadManager.getDownload(url);
        if (task != null) {
          _setupTaskListener(task);
        }
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding batch downloads: $e');
      }
      rethrow;
    }
  }

  void _setupTaskListener(DownloadTask task) {
    // Cancel existing listener if any
    _statusListeners[task.request.url]?.cancel();

    // Listen to status changes
    task.status.addListener(() {
      notifyListeners();
      
      // Add to history when completed
      if (task.status.value == DownloadStatus.completed) {
        _addToHistory(task);
      }
    });

    // Listen to progress changes
    task.progress.addListener(() {
      notifyListeners();
    });
  }

  Future<void> _addToHistory(DownloadTask task) async {
    try {
      final file = File(task.request.path);
      if (await file.exists()) {
        final fileSize = await file.length();
        final filename = file.path.split(Platform.pathSeparator).last;
        
        // Check if already in history
        final existingIndex = _history.indexWhere((item) => item.url == task.request.url);
        final historyItem = DownloadHistoryItem(
          url: task.request.url,
          filename: filename,
          path: task.request.path,
          completedAt: DateTime.now(),
          fileSize: fileSize,
        );

        if (existingIndex >= 0) {
          _history[existingIndex] = historyItem;
        } else {
          _history.insert(0, historyItem);
        }

        await _saveHistory();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to history: $e');
      }
    }
  }

  Future<void> pauseDownload(String url) async {
    await _downloadManager.pauseDownload(url);
    notifyListeners();
  }

  Future<void> resumeDownload(String url) async {
    await _downloadManager.resumeDownload(url);
    notifyListeners();
  }

  Future<void> cancelDownload(String url) async {
    await _downloadManager.cancelDownload(url);
    notifyListeners();
  }

  Future<void> removeDownload(String url) async {
    await _downloadManager.removeDownload(url);
    _statusListeners[url]?.cancel();
    _statusListeners.remove(url);
    notifyListeners();
  }

  Future<void> removeFromHistory(String url) async {
    _history.removeWhere((item) => item.url == url);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  void setMaxConcurrentDownloads(int count) {
    _downloadManager.maxConcurrentTasks = count;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final subscription in _statusListeners.values) {
      subscription.cancel();
    }
    _statusListeners.clear();
    super.dispose();
  }
}

