import 'dart:io';

import 'package:executable/executable.dart';
import 'package:test/test.dart';

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

  test('Test run method executes command', () async {
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test(
    'Test run method throws ProcessException if executable not found',
    () async {
      final notFound = Executable('non_existent_executable_12345');
      expect(() => notFound.run([]), throwsA(isA<ProcessException>()));
    },
  );

  test('Test runSync method executes command', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test(
    'Test runSync method throws ProcessException if executable not found',
    () {
      final notFound = Executable('non_existent_executable_12345');
      expect(() => notFound.runSync([]), throwsA(isA<ProcessException>()));
    },
  );
}
