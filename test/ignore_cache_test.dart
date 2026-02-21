import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('Test executable cache ignore', () async {
    // Create a temporary directory
    final tempDir = await Directory.systemTemp.createTemp('executable_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = 'test_executable_ignore_cache';
    if (Platform.isWindows) {
      cmdName += '.bat';
    }

    final exePath = '${tempDir.path}${Platform.pathSeparator}$cmdName';

    // Create dummy executable
    final file = File(exePath);
    if (Platform.isWindows) {
      await file.writeAsString('@echo off\necho hello');
    } else {
      await file.writeAsString('#!/bin/sh\necho hello');
      await Process.run('chmod', ['+x', exePath]);
    }

    // Run the runner script with updated PATH
    final separator = Platform.isWindows ? ';' : ':';
    final envPath = Platform.environment['PATH'] ?? '';
    final newPath = '${tempDir.path}$separator$envPath';

    // On Windows, 'which' finds the command even without extension if it matches known extensions.
    // We pass the name without extension to verify typical usage.
    final cmdArg = 'test_executable_ignore_cache';

    final result = await Process.run(
      'dart',
      ['run', 'test/ignore_cache_runner.dart', cmdArg],
      environment: {...Platform.environment, 'PATH': newPath},
    );

    if (result.exitCode != 0) {
      print('Runner stdout: ${result.stdout}');
      print('Runner stderr: ${result.stderr}');
    }

    expect(result.exitCode, 0, reason: 'Runner failed.');
  });
}
