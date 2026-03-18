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
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable runSync', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test executable run throws ProcessException if not found', () async {
    final fakeExe = Executable('non_existent_executable_12345');
    expect(
      () async => await fakeExe.run(['--version']),
      throwsA(isA<ProcessException>()),
    );
  });

  test('Test executable runSync throws ProcessException if not found', () {
    final fakeExe = Executable('non_existent_executable_12345');
    expect(
      () => fakeExe.runSync(['--version']),
      throwsA(isA<ProcessException>()),
    );
  });
}
