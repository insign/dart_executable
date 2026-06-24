import 'dart:io';
import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  group('Caching behavior', () {
    test('workingDirectory utilizes cache', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'executable_cache_wd_',
      );
      final scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
      final executablePath =
          '${tempDir.path}${Platform.pathSeparator}$scriptName';
      final file = File(executablePath);

      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho hello');
      } else {
        await file.writeAsString('#!/bin/sh\necho hello');
        await Process.run('chmod', ['+x', executablePath]);
      }

      final exe = Executable('.${Platform.pathSeparator}$scriptName');

      // First find: should populate cache
      final found1 = await exe.find(workingDirectory: tempDir.path);
      expect(found1, isNotNull);

      // Delete the file to prove the next result comes from cache
      await file.delete();

      // Second find: should return cached path even though file is deleted
      final found2 = await exe.find(workingDirectory: tempDir.path);
      expect(found2, isNotNull);
      expect(found2, equals(found1));

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('findSync workingDirectory utilizes cache', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'executable_cache_wdsync_',
      );
      final scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
      final executablePath =
          '${tempDir.path}${Platform.pathSeparator}$scriptName';
      final file = File(executablePath);

      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho hello');
      } else {
        await file.writeAsString('#!/bin/sh\necho hello');
        await Process.run('chmod', ['+x', executablePath]);
      }

      final exe = Executable('.${Platform.pathSeparator}$scriptName');

      // First find: should populate cache
      final found1 = exe.findSync(workingDirectory: tempDir.path);
      expect(found1, isNotNull);

      // Delete the file to prove the next result comes from cache
      await file.delete();

      // Second find: should return cached path even though file is deleted
      final found2 = exe.findSync(workingDirectory: tempDir.path);
      expect(found2, isNotNull);
      expect(found2, equals(found1));

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
  });
}
