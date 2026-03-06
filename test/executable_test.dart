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

  test('Test run method executes successfully', () async {
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test run method throws ProcessException on failure', () async {
    final missing = Executable('non_existent_command_12345');
    expect(() => missing.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test runSync method executes successfully', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test runSync method throws ProcessException on failure', () {
    final missing = Executable('non_existent_command_12345');
    expect(() => missing.runSync([]), throwsA(isA<ProcessException>()));
  });
}
