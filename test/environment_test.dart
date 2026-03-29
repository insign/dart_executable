import 'dart:io';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable with custom environment', () {
    late Directory tempDir;
    late String executablePath;
    late String scriptName;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
      scriptName = Platform.isWindows
          ? 'custom_env_script.bat'
          : 'custom_env_script';
      executablePath = '${tempDir.path}${Platform.pathSeparator}$scriptName';

      final file = File(executablePath);
      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho custom_env');
      } else {
        await file.writeAsString('#!/bin/sh\necho custom_env');
        await Process.run('chmod', ['+x', executablePath]);
      }
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('find and findSync with custom environment PATH', () async {
      final exeName = scriptName; // Searching by name, relying on PATH
      final executable = Executable(exeName);

      // Should not be found without the custom PATH
      final foundWithoutCustomEnv = await executable.find();
      expect(foundWithoutCustomEnv, isNull);

      final foundSyncWithoutCustomEnv = executable.findSync();
      expect(foundSyncWithoutCustomEnv, isNull);

      // Create a custom environment with the temp directory in PATH
      final customPath = tempDir.path;
      final separator = Platform.isWindows ? ';' : ':';
      final currentPath = Platform.environment['PATH'] ?? '';
      final newPath = '$customPath$separator$currentPath';

      final env = {'PATH': newPath};

      // Should be found with the custom environment
      final foundWithCustomEnv = await executable.find(environment: env);
      expect(foundWithCustomEnv, isNotNull);
      expect(
        File(foundWithCustomEnv!).absolute.path,
        File(executablePath).absolute.path,
      );

      // Sync version
      final foundSyncWithCustomEnv = executable.findSync(environment: env);
      expect(foundSyncWithCustomEnv, isNotNull);
      expect(
        File(foundSyncWithCustomEnv!).absolute.path,
        File(executablePath).absolute.path,
      );

      // Verify cache is not polluted
      final foundAfterCustomEnv = await executable.find();
      expect(
        foundAfterCustomEnv,
        isNull,
        reason: 'Cache should not have been updated with custom env result',
      );

      final foundSyncAfterCustomEnv = executable.findSync();
      expect(
        foundSyncAfterCustomEnv,
        isNull,
        reason: 'Cache should not have been updated with custom env result',
      );
    });

    test('run and runSync with custom environment PATH', () async {
      final exeName = scriptName;
      final executable = Executable(exeName);

      // Should throw when run without custom PATH
      expect(() => executable.run([]), throwsA(isA<ProcessException>()));

      expect(() => executable.runSync([]), throwsA(isA<ProcessException>()));

      // Create a custom environment with the temp directory in PATH
      final customPath = tempDir.path;
      final separator = Platform.isWindows ? ';' : ':';
      final currentPath = Platform.environment['PATH'] ?? '';
      final newPath = '$customPath$separator$currentPath';

      final env = {'PATH': newPath};

      // Should run successfully with the custom environment
      final result = await executable.run([], environment: env);
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'custom_env');

      // Sync version
      final resultSync = executable.runSync([], environment: env);
      expect(resultSync.exitCode, 0);
      expect(resultSync.stdout.toString().trim(), 'custom_env');
    });

    test('find with includeParentEnvironment = false', () async {
      // Look for a common command that exists in parent env
      final lsCmd = Platform.isWindows ? 'cmd' : 'ls';
      final executable = Executable(lsCmd);

      // Should be found normally
      expect(await executable.find(), isNotNull);

      // When includeParentEnvironment is false and we don't provide a PATH, it shouldn't find it
      // (unless it's in the current directory or something, but usually it fails)
      // This test might be a bit flaky across different systems if the command is somehow found
      // outside of PATH, but it works for standard PATH-based resolution.
      final foundWithoutParentEnv = await executable.find(
        environment: {'PATH': ''},
        includeParentEnvironment: false,
      );

      if (!Platform.isWindows) {
        // On windows, 'cmd' might be resolved through other means
        expect(foundWithoutParentEnv, isNull);
      }

      // Ensure cache was not affected
      expect(await executable.find(), isNotNull);
    });
  });
}
