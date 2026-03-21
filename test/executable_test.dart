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
    final tempDir = await Directory.systemTemp.createTemp(
      'executable_env_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = 'custom_env_cmd_12345';
    if (Platform.isWindows) {
      cmdName += '.bat';
    }

    final exePath = '${tempDir.path}${Platform.pathSeparator}$cmdName';
    final file = File(exePath);
    if (Platform.isWindows) {
      await file.writeAsString('@echo off\necho custom_env');
    } else {
      await file.writeAsString('#!/bin/sh\necho custom_env');
      await Process.run('chmod', ['+x', exePath]);
    }

    final cmdArg = 'custom_env_cmd_12345';
    final customExecutable = Executable(cmdArg);

    // Should not be found without custom environment
    final notFoundResult = await customExecutable.find();
    expect(notFoundResult, isNull);

    // Should be found with custom environment (will bypass cache automatically)
    final separator = Platform.isWindows ? ';' : ':';
    final envPath = Platform.environment['PATH'] ?? '';
    final newPath = '${tempDir.path}$separator$envPath';

    final foundResult = await customExecutable.find(
      environment: {...Platform.environment, 'PATH': newPath},
    );
    expect(foundResult, isNotNull);

    // Cache should not be poisoned: find without custom environment should still return null
    final notFoundResultAfter = await customExecutable.find();
    expect(notFoundResultAfter, isNull);

    // Sync find test
    final syncFoundResult = customExecutable.findSync(
      environment: {...Platform.environment, 'PATH': newPath},
    );
    expect(syncFoundResult, isNotNull);

    // Cache should not be poisoned: findSync without custom environment should still return null
    final syncNotFoundResultAfter = customExecutable.findSync();
    expect(syncNotFoundResultAfter, isNull);
  });
}
