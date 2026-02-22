import 'dart:io';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable with full/relative path', () {
    late Directory tempDir;
    late String exePath;
    late String scriptName;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_test_path_');
      scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
      exePath = '${tempDir.path}${Platform.pathSeparator}$scriptName';

      final file = File(exePath);
      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho hello');
      } else {
        await file.writeAsString('#!/bin/sh\necho hello');
        await Process.run('chmod', ['+x', exePath]);
      }
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds executable by full path', () async {
      final exe = Executable(exePath);
      final found = await exe.find();
      expect(found, isNotNull);
      // On Windows, paths might differ in case or separators, so normalize if needed?
      // But find() returns absolute path.
      expect(found, equals(exePath));
      expect(await exe.exists(), isTrue);
    });

    test('findSync finds executable by full path', () {
      final exe = Executable(exePath);
      final found = exe.findSync();
      expect(found, isNotNull);
      expect(found, equals(exePath));
      expect(exe.existsSync(), isTrue);
    });

    test('returns null for non-existing full path', () async {
      final nonExistent = '${tempDir.path}${Platform.pathSeparator}does_not_exist';
      final exe = Executable(nonExistent);
      expect(await exe.find(), isNull);
      expect(await exe.exists(), isFalse);
    });

    test('returns null for non-executable file (POSIX only)', () async {
      if (Platform.isWindows) return; // Windows executable check is complex/extension based

      final nonExePath = '${tempDir.path}/not_executable.txt';
      await File(nonExePath).writeAsString('content');
      // Ensure not executable
      await Process.run('chmod', ['-x', nonExePath]);

      final exe = Executable(nonExePath);
      expect(await exe.find(), isNull);
    });

    test('finds executable by relative path', () async {
      final originalCwd = Directory.current;
      try {
        Directory.current = tempDir.path;
        final relativePath = '.${Platform.pathSeparator}$scriptName';
        final exe = Executable(relativePath);
        final found = await exe.find();
        expect(found, isNotNull);
        final expected = File(relativePath).absolute.path;
        expect(File(found!).absolute.path, equals(expected));
      } finally {
        Directory.current = originalCwd;
      }
    });

    test('returns null for non-executable extension (Windows only)', () async {
      if (!Platform.isWindows) return;

      final nonExePath = '${tempDir.path}\\not_executable.txt';
      await File(nonExePath).writeAsString('content');

      final exe = Executable(nonExePath);
      expect(await exe.find(), isNull);
    });
  });
}
