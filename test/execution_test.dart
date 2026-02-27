import 'dart:io';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable execution', () {
    test('run executes command', () async {
      // Use 'dart' executable as it should be available
      final dart = Executable('dart');
      final result = await dart.run(['--version']);
      expect(result.exitCode, 0);
    });

    test('runSync executes command', () {
      final dart = Executable('dart');
      final result = dart.runSync(['--version']);
      expect(result.exitCode, 0);
    });

    test('run throws if not found', () async {
      final notFound = Executable('non_existent_executable_xyz');
      expect(() => notFound.run([]), throwsA(isA<ProcessException>()));
    });

    test('runSync throws if not found', () {
      final notFound = Executable('non_existent_executable_xyz');
      expect(() => notFound.runSync([]), throwsA(isA<ProcessException>()));
    });

    test('run supports stdout', () async {
      final echo = Executable('echo');
      if (await echo.exists()) {
        final result = await echo.run(['hello']);
        expect(result.stdout.toString().trim(), 'hello');
      }
    });
  });
}
