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

  test('Test executable with custom environment', () async {
    final tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    var scriptName = 'custom_env_script';
    if (Platform.isWindows) {
      scriptName += '.bat';
    }

    final scriptPath = '${tempDir.path}${Platform.pathSeparator}$scriptName';
    final file = File(scriptPath);

    if (Platform.isWindows) {
      await file.writeAsString('@echo off\necho custom_env');
    } else {
      await file.writeAsString('#!/bin/sh\necho custom_env');
      await Process.run('chmod', ['+x', scriptPath]);
    }

    final executable = Executable('custom_env_script');

    // Should not find the executable initially
    expect(await executable.find(), isNull);
    expect(executable.findSync(), isNull);

    final separator = Platform.isWindows ? ';' : ':';
    final currentPath = Platform.environment['PATH'] ?? '';
    final envPath = '${tempDir.path}$separator$currentPath';

    final customEnv = {'PATH': envPath};

    // Should find the executable with custom environment
    final foundPath = await executable.find(environment: customEnv);
    expect(foundPath, isNotNull);

    final foundSyncPath = executable.findSync(environment: customEnv);
    expect(foundSyncPath, isNotNull);

    // Verify cache is bypassed when using custom environment
    expect(await executable.find(), isNull);
    expect(executable.findSync(), isNull);

    // Test running with custom environment
    final resultAsync = await executable.run([], environment: customEnv);
    expect(resultAsync.exitCode, 0);
    expect(resultAsync.stdout.toString().trim(), 'custom_env');

    final resultSync = executable.runSync([], environment: customEnv);
    expect(resultSync.exitCode, 0);
    expect(resultSync.stdout.toString().trim(), 'custom_env');
  });
}
