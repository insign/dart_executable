import 'dart:io';

import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable custom environment', () {
    late Directory tempDir;
    late String executablePath;
    late String scriptName;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
      scriptName = Platform.isWindows
          ? 'custom_script.bat'
          : 'custom_script.sh';
      executablePath = '${tempDir.path}${Platform.pathSeparator}$scriptName';

      final file = File(executablePath);
      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho hello from env');
      } else {
        await file.writeAsString('#!/bin/sh\necho hello from env');
        await Process.run('chmod', ['+x', executablePath]);
      }
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('finds executable with custom PATH environment', () async {
      final executable = Executable(scriptName);

      // Default env should fail
      var found = await executable.find();
      expect(found, isNull);

      // Custom env should succeed
      found = await executable.find(
        environment: {'PATH': tempDir.path},
        includeParentEnvironment: false,
      );

      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );

      expect(
        await executable.exists(
          environment: {'PATH': tempDir.path},
          includeParentEnvironment: false,
        ),
        isTrue,
      );
    });

    test('findSync finds executable with custom PATH environment', () {
      final executable = Executable(scriptName);

      // Default env should fail
      var found = executable.findSync();
      expect(found, isNull);

      // Custom env should succeed
      found = executable.findSync(
        environment: {'PATH': tempDir.path},
        includeParentEnvironment: false,
      );

      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );

      expect(
        executable.existsSync(
          environment: {'PATH': tempDir.path},
          includeParentEnvironment: false,
        ),
        isTrue,
      );
    });

    test('run successfully uses custom environment', () async {
      final executable = Executable(scriptName);

      final result = await executable.run(
        [],
        environment: {'PATH': tempDir.path},
        includeParentEnvironment: false,
      );

      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'hello from env');
    });

    test('runSync successfully uses custom environment', () {
      final executable = Executable(scriptName);

      final result = executable.runSync(
        [],
        environment: {'PATH': tempDir.path},
        includeParentEnvironment: false,
      );

      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'hello from env');
    });
  });
}
