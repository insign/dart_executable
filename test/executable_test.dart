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

  test('Test run method with valid command', () async {
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test runSync method with valid command', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test(
    'Test run method with invalid command throws ProcessException',
    () async {
      final cmd = Executable('this_command_does_not_exist_xyz');
      expect(() async => await cmd.run([]), throwsA(isA<ProcessException>()));
    },
  );

  test('Test runSync method with invalid command throws ProcessException', () {
    final cmd = Executable('this_command_does_not_exist_xyz');
    expect(() => cmd.runSync([]), throwsA(isA<ProcessException>()));
  });
}
