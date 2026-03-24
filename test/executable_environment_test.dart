import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  group('Executable custom environment', () {
    late Directory tempDir;
    late String testExeName;
    late String testExePath;
    late Map<String, String> customEnv;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_test_');
      testExeName = Platform.isWindows ? 'dummy_test_exe.bat' : 'dummy_test_exe.sh';
      testExePath = p.join(tempDir.path, testExeName);

      if (Platform.isWindows) {
        await File(testExePath).writeAsString('@echo dummy_output');
      } else {
        final file = File(testExePath);
        await file.writeAsString('#!/bin/sh\necho dummy_output\n');
        // Make it executable
        await Process.run('chmod', ['+x', testExePath]);
      }

      customEnv = {
        'PATH': tempDir.path,
      };
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('find returns null if not in parent environment and includeParentEnvironment is false', () async {
      final exe = Executable(testExeName);
      final path = await exe.find(environment: {}, includeParentEnvironment: false);
      expect(path, isNull);
    });

    test('findSync returns null if not in parent environment and includeParentEnvironment is false', () {
      final exe = Executable(testExeName);
      final path = exe.findSync(environment: {}, includeParentEnvironment: false);
      expect(path, isNull);
    });

    test('find uses custom environment PATH', () async {
      final exe = Executable(testExeName);
      final path = await exe.find(environment: customEnv, includeParentEnvironment: false);
      expect(path, isNotNull);
      expect(p.normalize(path!), p.normalize(testExePath));
    });

    test('findSync uses custom environment PATH', () {
      final exe = Executable(testExeName);
      final path = exe.findSync(environment: customEnv, includeParentEnvironment: false);
      expect(path, isNotNull);
      expect(p.normalize(path!), p.normalize(testExePath));
    });

    test('run executes successfully with custom environment', () async {
      final exe = Executable(testExeName);
      final result = await exe.run(
        [],
        environment: customEnv,
        includeParentEnvironment: false,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'dummy_output');
    });

    test('runSync executes successfully with custom environment', () {
      final exe = Executable(testExeName);
      final result = exe.runSync(
        [],
        environment: customEnv,
        includeParentEnvironment: false,
      );
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'dummy_output');
    });

    test('exists and existsSync work with custom environment', () async {
      final exe = Executable(testExeName);

      expect(await exe.exists(environment: customEnv, includeParentEnvironment: false), isTrue);
      expect(exe.existsSync(environment: customEnv, includeParentEnvironment: false), isTrue);

      expect(await exe.exists(environment: {}, includeParentEnvironment: false), isFalse);
      expect(exe.existsSync(environment: {}, includeParentEnvironment: false), isFalse);
    });
  });
}
