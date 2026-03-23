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

  test('Test executable environment variables in find', () async {
    final tempDir = Directory.systemTemp.createTempSync('executable_test_');
    try {
      final dummyExecutableName =
          'dummy_executable_test_${DateTime.now().millisecondsSinceEpoch}${Platform.isWindows ? '.bat' : ''}';
      final dummyExecutablePath = '${tempDir.path}/$dummyExecutableName';
      final dummyExecutable = File(dummyExecutablePath);

      if (Platform.isWindows) {
        dummyExecutable.writeAsStringSync('@echo off\necho hello');
      } else {
        dummyExecutable.writeAsStringSync('#!/bin/sh\necho hello');
        Process.runSync('chmod', ['+x', dummyExecutablePath]);
      }

      final exec = Executable(dummyExecutableName);

      // Deve falhar, não está no PATH global
      final resultGlobal = await exec.find();
      expect(resultGlobal, isNull);

      // Deve achar, pois passamos o ambiente correto
      final env = {'PATH': tempDir.path};
      final resultEnv = await exec.find(
        environment: env,
        includeParentEnvironment: false,
      );
      expect(resultEnv, isNotNull);

      final resultEnvSync = exec.findSync(
        environment: env,
        includeParentEnvironment: false,
      );
      expect(resultEnvSync, isNotNull);

      // Testar execução
      final runResult = await exec.run(
        [],
        environment: env,
        includeParentEnvironment: false,
      );
      expect(runResult.exitCode, 0);

      final runSyncResult = exec.runSync(
        [],
        environment: env,
        includeParentEnvironment: false,
      );
      expect(runSyncResult.exitCode, 0);
    } finally {
      tempDir.deleteSync(recursive: true);
    }
  });
}
