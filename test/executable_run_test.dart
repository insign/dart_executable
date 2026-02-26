import 'dart:io';
import 'package:executable/executable.dart';
import 'package:test/test.dart';

void main() {
  group('Executable run', () {
    test('run executes the command', () async {
      final dart = Executable('dart');
      final result = await dart.run(['--version']);
      expect(result.exitCode, 0);
      // Dart version info might be in stdout or stderr depending on version
      final output = result.stdout.toString() + result.stderr.toString();
      expect(output, contains('Dart SDK'));
    });

    test('runSync executes the command', () {
      final dart = Executable('dart');
      final result = dart.runSync(['--version']);
      expect(result.exitCode, 0);
      final output = result.stdout.toString() + result.stderr.toString();
      expect(output, contains('Dart SDK'));
    });

    test('run throws ProcessException if executable not found', () async {
      final nonExistent = Executable('non_existent_executable_12345');
      expect(
        () async => await nonExistent.run([]),
        throwsA(isA<ProcessException>()),
      );
    });

    test('runSync throws ProcessException if executable not found', () {
      final nonExistent = Executable('non_existent_executable_12345');
      expect(() => nonExistent.runSync([]), throwsA(isA<ProcessException>()));
    });
  });
}
