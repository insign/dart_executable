import 'dart:io';

import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  test('Test find with custom environment', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'executable_env_test_',
    );
    addTearDown(() => tempDir.delete(recursive: true));

    var cmdName = 'dummy_env_cmd';
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

    final exe = Executable('dummy_env_cmd');

    // Should not find it without custom env
    final pathWithoutEnv = await exe.find(ignoreCache: true);
    expect(pathWithoutEnv, isNull);

    // Should find it with custom env
    final customEnv = {'PATH': tempDir.path};
    final pathWithEnv = await exe.find(
      environment: customEnv,
      includeParentEnvironment: false,
    );
    expect(pathWithEnv, isNotNull);

    // Sync should behave similarly
    final pathSyncWithoutEnv = exe.findSync(ignoreCache: true);
    expect(pathSyncWithoutEnv, isNull);

    final pathSyncWithEnv = exe.findSync(
      environment: customEnv,
      includeParentEnvironment: false,
    );
    expect(pathSyncWithEnv, isNotNull);

    // Verify cache poisoning doesn't happen
    final cachedPath = await exe.find();
    expect(cachedPath, isNull);
  });
}
