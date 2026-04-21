import 'dart:io';

import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  test('Test executable existence', () async {
    final ls = Executable('ls');
    final result = await ls.exists();
    expect(result, true);
  });

  test('Test executable path', () async {
    final ls = Executable('ls');
    final result = await ls.find();
    expect(result, isNotNull);
  });

  test('Test executable run', () async {
    final echo = Executable('echo');
    final result = await echo.run(['hello']);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable runSync', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello']);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable run with ignoreCache', () async {
    final echo = Executable('echo');
    final result = await echo.run(['hello'], ignoreCache: true);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable runSync with ignoreCache', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello'], ignoreCache: true);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable run exception', () async {
    final nonexistent = Executable('nonexistent_executable_12345');
    await expectLater(
      () => nonexistent.run(['test']),
      throwsA(isA<ProcessException>()),
    );
  });

  test('Test executable runSync exception', () {
    final nonexistent = Executable('nonexistent_executable_12345');
    expect(
      () => nonexistent.runSync(['test']),
      throwsA(isA<ProcessException>()),
    );
  });

  group('Cache poisoning tests', () {
    test('find cache bypasses when includeParentEnvironment is false', () async {
      final exe = Executable('ls');

      // Call find to populate the cache
      await exe.find();

      // For process_run which(), even with includeParentEnvironment: false, it will fall back to using default Platform.environment
      // However, what we want to test is whether Executable's own caching logic is correctly bypassing cache when asked to.
      // So let's provide a completely dummy environment that will force which() to not find the executable.
      // Since our fix enforces bypassing cache when includeParentEnvironment is false, the result MUST be null.
      // This is because we ensure `shouldIgnoreCache = true` when includeParentEnvironment is false.
      final foundWithoutParent = await exe.find(
        environment: {'PATH': ''},
        includeParentEnvironment: false,
      );

      expect(foundWithoutParent, isNull);
    });

    test('findSync cache bypasses when includeParentEnvironment is false', () {
      final exe = Executable('date');

      exe.findSync();

      final foundWithoutParent = exe.findSync(
        environment: {'PATH': ''},
        includeParentEnvironment: false,
      );

      expect(foundWithoutParent, isNull);
    });
  });

  group('Custom environment tests', () {
    late Directory tempDir;
    late String scriptName;
    late String executablePath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
      scriptName = Platform.isWindows
          ? 'custom_script.bat'
          : 'custom_script.sh';
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

    Map<String, String> getCustomEnv() {
      final separator = Platform.isWindows ? ';' : ':';
      final envPath = Platform.environment['PATH'] ?? '';
      return {
        ...Platform.environment,
        'PATH': '${tempDir.path}$separator$envPath',
      };
    }

    test('Test executable find with custom environment', () async {
      final exe = Executable(scriptName);

      // Should not find it without custom env
      expect(await exe.find(), isNull);

      // Should find it with custom env
      final found = await exe.find(environment: getCustomEnv());
      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );
    });

    test('Test executable findSync with custom environment', () {
      final exe = Executable(scriptName);

      // Should not find it without custom env
      expect(exe.findSync(), isNull);

      // Should find it with custom env
      final found = exe.findSync(environment: getCustomEnv());
      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(executablePath).absolute.path),
      );
    });

    test('Test executable run with custom environment', () async {
      final exe = Executable(scriptName);

      // Run with custom environment
      final result = await exe.run([], environment: getCustomEnv());
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'custom_env');
    });

    test('Test executable runSync with custom environment', () {
      final exe = Executable(scriptName);

      // Run with custom environment
      final result = exe.runSync([], environment: getCustomEnv());
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'custom_env');
    });
  });

}
