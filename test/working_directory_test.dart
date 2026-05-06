import 'dart:io';
import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  group('workingDirectory support tests', () {
    late Directory tempDir;
    late String scriptName;
    late String scriptPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_wd_test_');
      scriptName = Platform.isWindows ? 'local_script.bat' : 'local_script.sh';
      scriptPath = '${tempDir.path}${Platform.pathSeparator}$scriptName';

      final file = File(scriptPath);
      if (Platform.isWindows) {
        await file.writeAsString('@echo off\necho success');
      } else {
        await file.writeAsString('#!/bin/sh\necho success');
        await Process.run('chmod', ['+x', scriptPath]);
      }
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('find correctly resolves relative path using workingDirectory', () async {
      final exe = Executable('./$scriptName');

      // Sem workingDirectory o executável relativo não é encontrado (pois o CWD atual do processo de teste não tem o script)
      expect(await exe.find(), isNull);

      // Com workingDirectory ele deve encontrar e retornar o caminho absoluto correto do script criado
      final found = await exe.find(workingDirectory: tempDir.path);
      expect(found, isNotNull);
      expect(
        File(found!).absolute.path,
        equals(File(scriptPath).absolute.path),
      );
    });

    test(
      'findSync correctly resolves relative path using workingDirectory',
      () {
        final exe = Executable('./$scriptName');

        expect(exe.findSync(), isNull);

        final found = exe.findSync(workingDirectory: tempDir.path);
        expect(found, isNotNull);
        expect(
          File(found!).absolute.path,
          equals(File(scriptPath).absolute.path),
        );
      },
    );

    test('exists and existsSync work with workingDirectory', () async {
      final exe = Executable('./$scriptName');

      expect(await exe.exists(), isFalse);
      expect(exe.existsSync(), isFalse);

      expect(await exe.exists(workingDirectory: tempDir.path), isTrue);
      expect(exe.existsSync(workingDirectory: tempDir.path), isTrue);
    });

    test(
      'run successfully executes relative executable using workingDirectory',
      () async {
        final exe = Executable('./$scriptName');

        // run using workingDirectory
        final result = await exe.run([], workingDirectory: tempDir.path);
        expect(result.exitCode, 0);
        expect(result.stdout.toString().trim(), 'success');
      },
    );

    test(
      'runSync successfully executes relative executable using workingDirectory',
      () {
        final exe = Executable('./$scriptName');

        // runSync using workingDirectory
        final result = exe.runSync([], workingDirectory: tempDir.path);
        expect(result.exitCode, 0);
        expect(result.stdout.toString().trim(), 'success');
      },
    );
    test(
      'find correctly resolves absolute path ignoring workingDirectory',
      () async {
        final exePath = Platform.isWindows
            ? 'C:\\absolute\\path\\cmd.exe'
            : '/absolute/path/cmd.sh';
        final exe = Executable(exePath);

        final found = await exe.find(workingDirectory: '/some/other/dir');
        // If it tries to resolve, it would crash or create a malformed path.
        // Since the path doesn't exist, it should return null safely without throwing UnsupportedError.
        expect(found, isNull);
      },
    );

    test(
      'findSync correctly resolves absolute path ignoring workingDirectory',
      () {
        final exePath = Platform.isWindows
            ? 'C:\\absolute\\path\\cmd.exe'
            : '/absolute/path/cmd.sh';
        final exe = Executable(exePath);

        final found = exe.findSync(workingDirectory: '/some/other/dir');
        expect(found, isNull);
      },
    );
  });
}
