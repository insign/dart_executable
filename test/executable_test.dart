import 'package:test/test.dart';
import 'package:executable/executable.dart';
import 'dart:io';

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
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable runSync', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test missing executable run', () async {
    final missing = Executable('missing_executable_123');
    expect(() => missing.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test missing executable runSync', () {
    final missing = Executable('missing_executable_123');
    expect(() => missing.runSync([]), throwsA(isA<ProcessException>()));
  });
}
