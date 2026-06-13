import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'download_request.dart';
import 'download_status.dart';
import 'download_task.dart';

class DownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Map<String, Process> _runningProcesses = {};
  final Queue<DownloadRequest> _queue = Queue();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  // var tasks = StreamController<DownloadTask>();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({
    int? maxConcurrentTasks,
  }) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }

    return _dm;
  }

  Future<void> download(String url, String savePath,
      {forceDownload = false}) async {
    Process? process;
    try {
      var task = getDownload(url);

      if (task == null || task.status.value == DownloadStatus.canceled) {
        return;
      }
      setStatus(task, DownloadStatus.downloading);

      final file = File(savePath.toString());
      final fileExist = await file.exists();
      final aria2File = File('${savePath.toString()}.aria2');
      final aria2FileExist = await aria2File.exists();

      if (fileExist && !aria2FileExist) {
        if (kDebugMode) {
          print("File Exists and is complete: $savePath");
        }
        task.progress.value = 1.0;
        setStatus(task, DownloadStatus.completed);
        return;
      }

      final directoryPath = file.parent.path;
      final filename = file.path.split(Platform.pathSeparator).last;

      // Ensure directory exists
      await Directory(directoryPath).create(recursive: true);

      // Load settings
      final prefs = await SharedPreferences.getInstance();
      final maxConnections = prefs.getInt('aria2_max_connections') ?? 16;
      final split = prefs.getInt('aria2_split') ?? 16;
      final minSplitSize = prefs.getString('aria2_min_split_size') ?? '1M';
      final fileAllocation = prefs.getString('aria2_file_allocation') ?? 'falloc';

      final arguments = [
        url,
        '--dir=$directoryPath',
        '--out=$filename',
        '--max-connection-per-server=$maxConnections',
        '--split=$split',
        '--min-split-size=$minSplitSize',
        '--file-allocation=$fileAllocation',
        '--summary-interval=1',
        '--continue=true',
        '--allow-overwrite=true',
      ];

      if (kDebugMode) {
        print('Running: aria2c ${arguments.join(' ')}');
      }

      process = await Process.start('aria2c', arguments);
      _runningProcesses[url] = process;

      final speedNotifier = task.speed;
      final etaNotifier = task.eta;

      final regex = RegExp(
          r'\[#\w+\s+([^\/]+)\/([^\(]+)\((\d+)%\)\s+CN:\d+\s+DL:(\S+)\s+ETA:(\S+)\]');

      final lines = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final percentage = int.tryParse(match.group(3) ?? '0') ?? 0;
          final speed = match.group(4) ?? '';
          final eta = match.group(5) ?? '';

          task.progress.value = percentage / 100.0;
          speedNotifier.value = speed;
          etaNotifier.value = eta;
        }
      }

      final exitCode = await process.exitCode;

      if (_runningProcesses[url] == process) {
        _runningProcesses.remove(url);
        if (exitCode == 0) {
          task.progress.value = 1.0;
          setStatus(task, DownloadStatus.completed);
        } else {
          if (task.status.value == DownloadStatus.downloading) {
            setStatus(task, DownloadStatus.failed);
          }
        }
      }
    } catch (e) {
      var task = getDownload(url)!;
      if (task.status.value != DownloadStatus.canceled &&
          task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
        rethrow;
      }
    } finally {
      if (_runningProcesses[url] == process) {
        _runningProcesses.remove(url);
      }
      runningTasks--;
      if (_queue.isNotEmpty) {
        _startExecution();
      }
    }
  }

  void disposeNotifiers(DownloadTask task) {
    // task.status.dispose();
    // task.progress.dispose();
  }

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;

      // tasks.add(task);
      if (status.isCompleted) {
        disposeNotifiers(task);
      }
    }
  }

  Future<DownloadTask?> addDownload(String url, String savedDir) async {
    if (url.isNotEmpty) {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      var isDirectory = await Directory(savedDir).exists();
      var downloadFilename = isDirectory
          ? savedDir + Platform.pathSeparator + getFileNameFromUrl(url)
          : savedDir;

      return _addDownloadRequest(DownloadRequest(url, downloadFilename));
    }
    return null;
  }

  Future<DownloadTask> _addDownloadRequest(
    DownloadRequest downloadRequest,
  ) async {
    if (_cache[downloadRequest.url] != null) {
      if (!_cache[downloadRequest.url]!.status.value.isCompleted &&
          _cache[downloadRequest.url]!.request == downloadRequest) {
        // Do nothing
        return _cache[downloadRequest.url]!;
      } else {
        _queue.remove(_cache[downloadRequest.url]);
      }
    }

    _queue.add(DownloadRequest(downloadRequest.url, downloadRequest.path));
    var task = DownloadTask(_queue.last);

    _cache[downloadRequest.url] = task;

    _startExecution();

    return task;
  }

  Future<void> pauseDownload(String url) async {
    if (kDebugMode) {
      print("Pause Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.paused);
    
    final process = _runningProcesses[url];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(url);
    }

    _queue.remove(task.request);
  }

  Future<void> cancelDownload(String url) async {
    if (kDebugMode) {
      print("Cancel Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.canceled);
    _queue.remove(task.request);
    
    final process = _runningProcesses[url];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(url);
    }

    // Clean up partial files asynchronously
    Future.delayed(const Duration(milliseconds: 100), () async {
      final file = File(task.request.path);
      final ariaFile = File('${task.request.path}.aria2');
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      if (await ariaFile.exists()) {
        try {
          await ariaFile.delete();
        } catch (_) {}
      }
    });
  }

  Future<void> resumeDownload(String url) async {
    if (kDebugMode) {
      print("Resume Download");
    }
    var task = getDownload(url)!;
    setStatus(task, DownloadStatus.downloading);
    _queue.add(task.request);

    _startExecution();
  }

  Future<void> removeDownload(String url) async {
    cancelDownload(url);
    _cache.remove(url);
  }

  // Do not immediately call getDownload After addDownload, rather use the returned DownloadTask from addDownload
  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url,
      {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values.toList();
  }

  // Batch Download Mechanism
  Future<void> addBatchDownloads(List<String> urls, String savedDir) async {
    urls.forEach((url) {
      addDownload(url, savedDir);
    });
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      pauseDownload(element);
    });
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      cancelDownload(element);
    });
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    urls.forEach((element) {
      resumeDownload(element);
    });
  }

  ValueNotifier<double> getBatchDownloadProgress(List<String> urls) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = urls.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getDownload(urls.first)?.progress ?? progress;
    }

    var progressMap = Map<String, double>();

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        progressMap[url] = 0.0;

        if (task.status.value.isCompleted) {
          progressMap[url] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        var progressListener;
        progressListener = () {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[url] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.status.removeListener(listener);
            task.progress.removeListener(progressListener);
          }
        };

        task.status.addListener(listener);
      } else {
        total--;
      }
    });

    return progress;
  }

  Future<List<DownloadTask?>?> whenBatchDownloadsComplete(List<String> urls,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<DownloadTask?>?>();

    var completed = 0;
    var total = urls.length;

    urls.forEach((url) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchDownloads(urls));
          }
        }

        var listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchDownloads(urls));
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    });

    return completer.future.timeout(timeout);
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      if (kDebugMode) {
        print('Concurrent workers: $runningTasks');
      }
      var currentRequest = _queue.removeFirst();

      download(currentRequest.url, currentRequest.path);

      await Future.delayed(Duration(milliseconds: 500), null);
    }
  }

  /// This function is used for get file name with extension from url
  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }
}
