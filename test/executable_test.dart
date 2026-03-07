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
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable runSync', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable run throws if not found', () async {
    final unknown = Executable('some_unknown_command_12345');
    expect(() => unknown.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test executable runSync throws if not found', () {
    final unknown = Executable('some_unknown_command_12345');
    expect(() => unknown.runSync([]), throwsA(isA<ProcessException>()));
  });
}
