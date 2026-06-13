import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dwn/services/download_manager/downloader.dart';
import 'package:dwn/services/download_manager/download_status.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadManager aria2c integration tests', () {
    late HttpServer server;
    late int serverPort;
    late Directory tempDir;

    setUpAll(() async {
      // Bind to a random local port
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      serverPort = server.port;

      // Set up a Range-supporting throttled file server
      server.listen((HttpRequest request) async {
        if (request.uri.path == '/dummy.bin') {
          final totalLength = 1024 * 1024; // 1 MB
          int start = 0;
          int end = totalLength - 1;
          
          final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
          bool isRange = false;
          if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
            isRange = true;
            final parts = rangeHeader.substring(6).split('-');
            start = int.tryParse(parts[0]) ?? 0;
            if (parts.length > 1 && parts[1].isNotEmpty) {
              end = int.tryParse(parts[1]) ?? end;
            }
          }
          
          final contentLength = end - start + 1;
          
          if (isRange) {
            request.response.statusCode = HttpStatus.partialContent;
            request.response.headers.set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$totalLength');
          } else {
            request.response.statusCode = HttpStatus.ok;
          }
          
          request.response.headers.contentType = ContentType.binary;
          request.response.headers.contentLength = contentLength;
          
          final data = List.generate(contentLength, (index) => 0);
          final chunkSize = 50 * 1024; // 50 KB chunks
          
          try {
            for (var offset = 0; offset < contentLength; offset += chunkSize) {
              final size = (offset + chunkSize > contentLength) ? (contentLength - offset) : chunkSize;
              request.response.add(data.sublist(offset, offset + size));
              await request.response.flush();
              await Future.delayed(const Duration(milliseconds: 50));
            }
          } catch (_) {
            // Socket might close on client abort/pause
          } finally {
            try {
              await request.response.close();
            } catch (_) {}
          }
        } else {
          request.response.statusCode = HttpStatus.notFound;
          request.response.close();
        }
      });

      // Create a temporary directory for downloads
      tempDir = await Directory.systemTemp.createTemp('dwn_test_');
    });

    tearDownAll(() async {
      await server.close(force: true);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('successfully downloads file using aria2c and parses progress', () async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({
        'aria2_max_connections': 4,
        'aria2_split': 4,
        'aria2_min_split_size': '1M',
        'aria2_file_allocation': 'none',
      });

      final dm = DownloadManager();
      final url = 'http://127.0.0.1:$serverPort/dummy.bin';
      final savePath = '${tempDir.path}/test_file.bin';

      final task = await dm.addDownload(url, savePath);
      expect(task, isNotNull);

      // Wait for completion (with timeout)
      final status = await task!.whenDownloadComplete(timeout: const Duration(seconds: 15));
      expect(status, equals(DownloadStatus.completed));
      expect(task.progress.value, equals(1.0));

      final downloadedFile = File(savePath);
      expect(await downloadedFile.exists(), isTrue);
      expect(await downloadedFile.length(), equals(1024 * 1024));
    });

    test('pauses and resumes download', () async {
      SharedPreferences.setMockInitialValues({
        'aria2_max_connections': 4,
        'aria2_split': 4,
        'aria2_min_split_size': '1M',
        'aria2_file_allocation': 'none',
      });

      final dm = DownloadManager();
      final url = 'http://127.0.0.1:$serverPort/dummy.bin';
      final savePath = '${tempDir.path}/test_file_pause.bin';

      final task = await dm.addDownload(url, savePath);
      expect(task, isNotNull);

      // Let it download a bit then pause
      await Future.delayed(const Duration(milliseconds: 500));
      await dm.pauseDownload(url);

      expect(task!.status.value, equals(DownloadStatus.paused));

      // Resume download
      await dm.resumeDownload(url);
      expect(task.status.value, equals(DownloadStatus.downloading));

      // Wait for completion
      final status = await task.whenDownloadComplete(timeout: const Duration(seconds: 15));
      expect(status, equals(DownloadStatus.completed));
      expect(await File(savePath).exists(), isTrue);
    });
  });

  group('Aria2c stdout parsing unit tests', () {
    test('correctly parses speed, ETA, and progress from aria2c status line', () {
      final regex = RegExp(
          r'\[#\w+\s+([^\/]+)\/([^\(]+)\((\d+)%\)\s+CN:\d+\s+DL:(\S+)\s+ETA:(\S+)\]');

      final line1 = '[#6750a5 16KiB/5.0MiB(0%) CN:1 DL:15KiB ETA:5m19s]';
      final match1 = regex.firstMatch(line1);
      expect(match1, isNotNull);
      expect(match1!.group(1), equals('16KiB'));
      expect(match1.group(2), equals('5.0MiB'));
      expect(match1.group(3), equals('0'));
      expect(match1.group(4), equals('15KiB'));
      expect(match1.group(5), equals('5m19s'));

      final line2 = '[#ea9885 1.1MiB/11MiB(10%) CN:16 DL:1.2MiB/s ETA:8s]';
      final match2 = regex.firstMatch(line2);
      expect(match2, isNotNull);
      expect(match2!.group(1), equals('1.1MiB'));
      expect(match2.group(2), equals('11MiB'));
      expect(match2.group(3), equals('10'));
      expect(match2.group(4), equals('1.2MiB/s'));
      expect(match2.group(5), equals('8s'));
    });
  });
}
