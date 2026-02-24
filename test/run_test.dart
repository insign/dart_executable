import 'dart:io';

import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable run', () {
    test('run with existing executable', () async {
      // Assuming 'dart' is available in the environment as it is running these tests
      final dart = Executable('dart');
      final result = await dart.run(['--version']);
      expect(result.exitCode, 0);
    });

    test('runSync with existing executable', () {
      final dart = Executable('dart');
      final result = dart.runSync(['--version']);
      expect(result.exitCode, 0);
    });

    test('run with non-existing executable', () async {
      final nonExistent = Executable('non_existent_executable_12345');
      expect(() => nonExistent.run([]), throwsA(isA<ProcessException>()));
    });

    test('runSync with non-existing executable', () {
      final nonExistent = Executable('non_existent_executable_12345');
      expect(() => nonExistent.runSync([]), throwsA(isA<ProcessException>()));
    });
  });
}
