import 'dart:io';

import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable with full or relative path', () {
    late Directory tempDir;
    late String executablePath;
    late String scriptName;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_test_path_');
      scriptName = Platform.isWindows ? 'script.bat' : 'script.sh';
      executablePath = '${tempDir.path}${Platform.pathSeparator}$scriptName';

      final file = File(executablePath);
      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho hello');
      } else {
        await file.writeAsString('#!/bin/sh\necho hello');
        await Process.run('chmod', ['+x', executablePath]);
      }
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds executable by full path', () async {
      final executable = Executable(executablePath);
      final found = await executable.find();

      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );
      expect(await executable.exists(), isTrue);
    });

    test('findSync finds executable by full path', () {
      final executable = Executable(executablePath);
      final found = executable.findSync();

      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );
      expect(executable.existsSync(), isTrue);
    });

    test('returns null for non-existing full path', () async {
      final missingPath =
          '${tempDir.path}${Platform.pathSeparator}does_not_exist';
      final executable = Executable(missingPath);

      expect(await executable.find(), isNull);
      expect(await executable.exists(), isFalse);
    });

    test('returns null for non-executable file on POSIX', () async {
      if (Platform.isWindows) {
        return;
      }

      final nonExecutablePath = '${tempDir.path}/not_executable.txt';
      await File(nonExecutablePath).writeAsString('content');
      await Process.run('chmod', ['-x', nonExecutablePath]);

      final executable = Executable(nonExecutablePath);
      expect(await executable.find(), isNull);
    });

    test('finds executable by relative path', () async {
      final originalCwd = Directory.current;
      try {
        Directory.current = tempDir.path;
        final relativePath = '.${Platform.pathSeparator}$scriptName';
        final executable = Executable(relativePath);
        final found = await executable.find();

        expect(found, isNotNull);
        // Compare checking if the real paths are matching, since p.normalize removes './'
        // and File('./').absolute retains it.
        expect(
          File(found!).resolveSymbolicLinksSync(),
          equals(File(relativePath).absolute.resolveSymbolicLinksSync()),
        );
      } finally {
        Directory.current = originalCwd;
      }
    });

    test('returns null for non-executable extension on Windows', () async {
      if (!Platform.isWindows) {
        return;
      }

      final nonExecutablePath = '${tempDir.path}\\not_executable.txt';
      await File(nonExecutablePath).writeAsString('content');

      final executable = Executable(nonExecutablePath);
      expect(await executable.find(), isNull);
    });
  });
}
