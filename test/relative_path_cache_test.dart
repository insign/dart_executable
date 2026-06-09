import 'dart:io';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  test('Cache should not poison relative paths when CWD changes', () async {
    final dir1 = await Directory.systemTemp.createTemp('dir1_');
    final dir2 = await Directory.systemTemp.createTemp('dir2_');

    final scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
    final script1 = '${dir1.path}/$scriptName';
    final script2 = '${dir2.path}/$scriptName';

    if (Platform.isWindows) {
      await File(script1).writeAsString('@echo off\necho dir1');
      await File(script2).writeAsString('@echo off\necho dir2');
    } else {
      await File(script1).writeAsString('#!/bin/sh\necho dir1');
      await Process.run('chmod', ['+x', script1]);

      await File(script2).writeAsString('#!/bin/sh\necho dir2');
      await Process.run('chmod', ['+x', script2]);
    }

    final originalCwd = Directory.current;

    try {
      // 1. Enter dir1 and find relative path
      Directory.current = dir1.path;
      final exe = Executable('.${Platform.pathSeparator}$scriptName');
      final res1 = await exe.find();
      expect(res1, isNotNull);
      expect(res1, contains('dir1_'));

      // 2. Enter dir2 and find relative path (same command string)
      Directory.current = dir2.path;
      final res2 = await exe.find();
      expect(res2, isNotNull);
      // If cached incorrectly, it will return the path from dir1
      expect(res2, contains('dir2_'));
    } finally {
      Directory.current = originalCwd;
      await dir1.delete(recursive: true);
      await dir2.delete(recursive: true);
    }
  });

  test(
    'Cache should not poison relative paths for findSync when CWD changes',
    () async {
      final dir1 = await Directory.systemTemp.createTemp('dir1_sync_');
      final dir2 = await Directory.systemTemp.createTemp('dir2_sync_');

      final scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
      final script1 = '${dir1.path}/$scriptName';
      final script2 = '${dir2.path}/$scriptName';

      if (Platform.isWindows) {
        await File(script1).writeAsString('@echo off\necho dir1');
        await File(script2).writeAsString('@echo off\necho dir2');
      } else {
        await File(script1).writeAsString('#!/bin/sh\necho dir1');
        await Process.run('chmod', ['+x', script1]);

        await File(script2).writeAsString('#!/bin/sh\necho dir2');
        await Process.run('chmod', ['+x', script2]);
      }

      final originalCwd = Directory.current;

      try {
        Directory.current = dir1.path;
        final exe = Executable('.${Platform.pathSeparator}$scriptName');
        final res1 = exe.findSync();
        expect(res1, isNotNull);
        expect(res1, contains('dir1_sync_'));

        Directory.current = dir2.path;
        final res2 = exe.findSync();
        expect(res2, isNotNull);
        expect(res2, contains('dir2_sync_'));
      } finally {
        Directory.current = originalCwd;
        await dir1.delete(recursive: true);
        await dir2.delete(recursive: true);
      }
    },
  );
}
