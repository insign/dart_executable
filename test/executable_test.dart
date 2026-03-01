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
    final echo = Executable('echo');
    final result = await echo.run(['hello']);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable runSync', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello']);
    expect(result.exitCode, 0);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable run throws ProcessException', () async {
    final notFound = Executable('some_non_existent_executable_123');
    expect(() => notFound.run(['test']), throwsA(isA<ProcessException>()));
  });

  test('Test executable runSync throws ProcessException', () {
    final notFound = Executable('some_non_existent_executable_123');
    expect(() => notFound.runSync(['test']), throwsA(isA<ProcessException>()));
  });
}
