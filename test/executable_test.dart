import 'dart:io';

import 'package:test/test.dart';
import 'package:executable/executable.dart';

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

  test('Test executable run', () async {
    // dart is cross-platform and available in path for dart tests
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable runSync', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test(
    'Test executable run throws ProcessException for non-existent command',
    () async {
      final nonExistent = Executable('this_cmd_does_not_exist_123');
      expect(() => nonExistent.run([]), throwsA(isA<ProcessException>()));
    },
  );

  test(
    'Test executable runSync throws ProcessException for non-existent command',
    () {
      final nonExistent = Executable('this_cmd_does_not_exist_123');
      expect(() => nonExistent.runSync([]), throwsA(isA<ProcessException>()));
    },
  );
}
