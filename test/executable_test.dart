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

  test('Test executable with custom environment bypasses cache correctly', () async {
    // We use a dummy executable name
    final dummyName = 'dummy_env_executable_123';
    final dummy = Executable(dummyName);

    // Initial check - should not exist
    expect(await dummy.exists(), false);
    expect(dummy.existsSync(), false);

    // Create a temporary directory with a dummy executable
    final tempDir = await Directory.systemTemp.createTemp('executable_env_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = dummyName;
    if (Platform.isWindows) {
      cmdName += '.bat';
    }

    final exePath = '${tempDir.path}${Platform.pathSeparator}$cmdName';
    final file = File(exePath);
    if (Platform.isWindows) {
      await file.writeAsString('@echo off\necho dummy');
    } else {
      await file.writeAsString('#!/bin/sh\necho dummy');
      await Process.run('chmod', ['+x', exePath]);
    }

    // Still should not be found in default environment due to negative caching or just missing from PATH
    expect(await dummy.exists(), false);
    expect(dummy.existsSync(), false);

    final separator = Platform.isWindows ? ';' : ':';
    final envPath = Platform.environment['PATH'] ?? '';
    final newPath = '${tempDir.path}$separator$envPath';
    final customEnv = {...Platform.environment, 'PATH': newPath};

    // With custom environment, it should be found
    final findResult = await dummy.find(environment: customEnv);
    expect(findResult, isNotNull);
    expect(File(findResult!).existsSync(), true);

    final findSyncResult = dummy.findSync(environment: customEnv);
    expect(findSyncResult, isNotNull);
    expect(File(findSyncResult!).existsSync(), true);

    expect(await dummy.exists(environment: customEnv), true);
    expect(dummy.existsSync(environment: customEnv), true);

    // Ensure cache wasn't poisoned
    expect(await dummy.exists(), false);
    expect(dummy.existsSync(), false);
  });
}
