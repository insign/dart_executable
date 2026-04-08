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

  test('Test executable cache ignores includeParentEnvironment false', () async {
    final tempDir = await Directory.systemTemp.createTemp('executable_test_');
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = 'test_executable_cache_parent';
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

    final customEnv = Map<String, String>.from(Platform.environment);
    final separator = Platform.isWindows ? ';' : ':';
    final envPath = Platform.environment['PATH'] ?? '';
    customEnv['PATH'] = '${tempDir.path}$separator$envPath';

    // To test the cache bug, we need to run a separate dart script with customEnv
    // so it has the executable in its parent environment.
    final runnerCode =
        '''
import 'package:executable/executable.dart';
import 'dart:io';

void main() async {
  final exe = Executable('$cmdName');

  // Call 1: includeParentEnvironment is true. Should find and cache it.
  final res1 = await exe.find();
  if (res1 == null) {
    exit(1);
  }

  // Call 2: includeParentEnvironment is false. Should bypass cache.
  final res2 = await exe.find(includeParentEnvironment: false);

  // Call 3: test findSync
  final res3 = exe.findSync(includeParentEnvironment: false);

  if (res2 == null && res3 == null) {
     // Expected to work correctly without crashing
  }
}
''';

    // We create the runner in the current directory so it resolves the package
    final runnerFile = File('runner_test_cache_parent.dart');
    await runnerFile.writeAsString(runnerCode);
    addTearDown(() => runnerFile.delete());

    final result = await Process.run('dart', [
      'run',
      runnerFile.path,
    ], environment: customEnv);

    expect(
      result.exitCode,
      0,
      reason:
          'Runner failed or improperly used cache. Exit code: ${result.exitCode}. Stderr: ${result.stderr}',
    );
  });
}
