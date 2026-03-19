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

  test('Test executable run exception', () async {
    final nonexistent = Executable('nonexistent_executable_12345');
    expect(
      () async => await nonexistent.run(['test']),
      throwsA(isA<ProcessException>()),
    );
  });

  test('Test executable runSync exception', () {
    final nonexistent = Executable('nonexistent_executable_12345');
    expect(
      () => nonexistent.runSync(['test']),
      throwsA(isA<ProcessException>()),
    );
  });
}
