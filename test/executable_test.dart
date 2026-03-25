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

  test('Test executable environment override', () async {
    // Test that find() resolves an executable when provided a custom PATH
    // and doesn't poison the cache for subsequent calls without environment.
    final tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = 'custom_env_cmd';
    if (Platform.isWindows) {
      cmdName += '.bat';
    }

    final exePath = '${tempDir.path}${Platform.pathSeparator}$cmdName';
    final file = File(exePath);
    if (Platform.isWindows) {
      await file.writeAsString('@echo off\necho hello');
    } else {
      await file.writeAsString('#!/bin/sh\necho hello');
      await Process.run('chmod', ['+x', exePath]);
    }

    final executable = Executable('custom_env_cmd');

    // Should not exist in normal environment
    final normalFind = await executable.find();
    expect(normalFind, isNull);

    // Provide custom PATH
    final separator = Platform.isWindows ? ';' : ':';
    final envPath = Platform.environment['PATH'] ?? '';
    final newPath = '${tempDir.path}$separator$envPath';
    final customEnv = {...Platform.environment, 'PATH': newPath};

    // Should find with custom environment
    final envFind = await executable.find(environment: customEnv);
    expect(envFind, isNotNull);

    // Test synchronous method as well
    final envFindSync = executable.findSync(environment: customEnv);
    expect(envFindSync, isNotNull);

    // Should still not exist in normal environment after custom env call
    final normalFindAfter = await executable.find();
    expect(normalFindAfter, isNull);
  });
}
