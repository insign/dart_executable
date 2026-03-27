import 'dart:io';

import 'package:test/test.dart';
import 'package:executable/executable.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Executable with custom environment', () {
    late Directory tempDir;
    late File dummyExecutable;
    late String pathVarName;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('executable_env_test');
      dummyExecutable = File(p.join(tempDir.path, 'my_dummy_command'));

      // Criar um script "falso" para ser um executável
      if (Platform.isWindows) {
        dummyExecutable = File('${dummyExecutable.path}.bat');
        await dummyExecutable.writeAsString('@echo off\necho dummy');
      } else {
        await dummyExecutable.writeAsString('#!/bin/sh\necho dummy');
        // Tornar executável
        await Process.run('chmod', ['+x', dummyExecutable.path]);
      }

      pathVarName = Platform.isWindows ? 'Path' : 'PATH';
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('find returns correct path when custom environment is provided', () async {
      final cmdName = p.basename(dummyExecutable.path);
      final exec = Executable(cmdName);

      // Com o ambiente padrão, não deve ser encontrado
      expect(await exec.find(), isNull);

      // Com o PATH alterado, deve ser encontrado
      final customEnv = {pathVarName: tempDir.path};
      final foundPath = await exec.find(
        environment: customEnv,
        includeParentEnvironment: true,
      );

      expect(foundPath, isNotNull);
      expect(p.normalize(foundPath!), p.normalize(dummyExecutable.absolute.path));
    });

    test('findSync returns correct path when custom environment is provided', () {
      final cmdName = p.basename(dummyExecutable.path);
      final exec = Executable(cmdName);

      expect(exec.findSync(), isNull);

      final customEnv = {pathVarName: tempDir.path};
      final foundPath = exec.findSync(
        environment: customEnv,
        includeParentEnvironment: true,
      );

      expect(foundPath, isNotNull);
      expect(p.normalize(foundPath!), p.normalize(dummyExecutable.absolute.path));
    });

    test('custom environment bypasses cache', () async {
      final cmdName = p.basename(dummyExecutable.path);
      final exec = Executable(cmdName);

      // A chamada sem cache_bypass salva null no cache
      expect(await exec.find(), isNull);

      final customEnv = {pathVarName: tempDir.path};
      // A chamada com environment deve ignorar o null salvo e realizar uma nova busca
      final foundPath = await exec.find(
        environment: customEnv,
        includeParentEnvironment: true,
      );

      expect(foundPath, isNotNull);
    });

    test('run successfully uses custom environment', () async {
      final cmdName = p.basename(dummyExecutable.path);
      final exec = Executable(cmdName);

      final customEnv = {pathVarName: tempDir.path};

      final result = await exec.run(
        [],
        environment: customEnv,
        includeParentEnvironment: true,
      );

      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'dummy');
    });

    test('runSync successfully uses custom environment', () {
      final cmdName = p.basename(dummyExecutable.path);
      final exec = Executable(cmdName);

      final customEnv = {pathVarName: tempDir.path};

      final result = exec.runSync(
        [],
        environment: customEnv,
        includeParentEnvironment: true,
      );

      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), 'dummy');
    });
  });
}
