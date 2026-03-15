import 'dart:io';
import 'package:test/test.dart';
import 'package:executable/executable.dart';

void main() {
  test('Test run method', () async {
    final echo = Executable('echo');
    final result = await echo.run(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test runSync method', () {
    final echo = Executable('echo');
    final result = echo.runSync(['hello']);
    expect(result.stdout.toString().trim(), 'hello');
  });

  test('Test run method with invalid executable', () async {
    final invalid = Executable('invalid_executable_123');
    expect(() => invalid.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test runSync method with invalid executable', () {
    final invalid = Executable('invalid_executable_123');
    expect(() => invalid.runSync([]), throwsA(isA<ProcessException>()));
  });
}
