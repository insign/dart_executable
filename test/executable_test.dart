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

  test('Test executable run async', () async {
    final echo = Executable('echo');
    final result = await echo.run(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable run sync', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test executable run exception when not found', () async {
    final nonExistent = Executable('non_existent_command_12345');
    expect(() => nonExistent.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test executable runSync exception when not found', () {
    final nonExistent = Executable('non_existent_command_12345');
    expect(() => nonExistent.runSync([]), throwsA(isA<ProcessException>()));
  });
}
