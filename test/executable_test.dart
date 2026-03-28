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
    final tempDir = Directory.systemTemp.createTempSync('exec_test');
    final tempFile = File('${tempDir.path}/my_dummy_exec');
    tempFile.writeAsStringSync('#!/bin/sh\necho "dummy"');

    // Make it executable on POSIX systems
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['+x', tempFile.path]);
    }

    final exec = Executable('my_dummy_exec');

    // Without custom environment, it should fail
    await expectLater(
      () => exec.run([], includeParentEnvironment: false),
      throwsA(isA<ProcessException>()),
    );

    // With custom environment containing tempDir in PATH, it should succeed
    final env = {'PATH': tempDir.path};

    if (!Platform.isWindows) {
      final result = await exec.run(
        [],
        environment: env,
        includeParentEnvironment: false,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'dummy');
    }

    // Synchronous execution test
    if (!Platform.isWindows) {
      final resultSync = exec.runSync(
        [],
        environment: env,
        includeParentEnvironment: false,
      );
      expect(resultSync.exitCode, 0);
      expect(resultSync.stdout.toString().trim(), 'dummy');
    }

    // Clean up
    tempDir.deleteSync(recursive: true);
  });
}
