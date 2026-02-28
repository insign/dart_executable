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
    final dartCmd = Executable('dart');
    final result = await dartCmd.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test runSync method executes successfully', () {
    final dartCmd = Executable('dart');
    final result = dartCmd.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test run throws ProcessException if not found', () async {
    final nonExistent = Executable('non_existent_executable_12345');
    expect(
      () async => await nonExistent.run([]),
      throwsA(isA<ProcessException>()),
    );
  });

  test('Test runSync throws ProcessException if not found', () {
    final nonExistent = Executable('non_existent_executable_12345');
    expect(() => nonExistent.runSync([]), throwsA(isA<ProcessException>()));
  });
}
