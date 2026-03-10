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

  test('Test non-existent executable run', () async {
    final nonExistent = Executable('this_executable_does_not_exist');
    expect(
      () async => await nonExistent.run(['hello']),
      throwsA(isA<ProcessException>()),
    );
  });

  test('Test non-existent executable runSync', () {
    final nonExistent = Executable('this_executable_does_not_exist');
    expect(
      () => nonExistent.runSync(['hello']),
      throwsA(isA<ProcessException>()),
    );
  });
}
