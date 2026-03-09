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

  test('Test executable run success', () async {
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable run throws ProcessException', () async {
    final nonexistent = Executable('nonexistent_cmd_xyz');
    expect(() => nonexistent.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test executable runSync success', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable runSync throws ProcessException', () {
    final nonexistent = Executable('nonexistent_cmd_xyz');
    expect(() => nonexistent.runSync([]), throwsA(isA<ProcessException>()));
  });
}
