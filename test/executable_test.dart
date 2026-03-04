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

  test('Test run method executes command', () async {
    final echo = Executable('echo');
    final result = await echo.run(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test runSync method executes command', () {
    final echo = Executable('echo');
    final result = echo.runSync(['world']);
    expect(result.stdout.toString().trim(), 'world');
  });

  test('Test run throws ProcessException for missing executable', () async {
    final missing = Executable('missing_executable_12345');
    expect(() => missing.run(['test']), throwsA(isA<ProcessException>()));
  });

  test('Test runSync throws ProcessException for missing executable', () {
    final missing = Executable('missing_executable_12345');
    expect(() => missing.runSync(['test']), throwsA(isA<ProcessException>()));
  });
}
