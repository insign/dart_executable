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

  test('Test run method (async)', () async {
    final dart = Executable('dart');
    final result = await dart.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test runSync method (sync)', () {
    final dart = Executable('dart');
    final result = dart.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test(
    'Test run method (async) throws ProcessException for missing executable',
    () async {
      final missingCmd = Executable('this_cmd_does_not_exist_123');
      expect(
        () async => await missingCmd.run(['--version']),
        throwsA(isA<ProcessException>()),
      );
    },
  );

  test(
    'Test runSync method (sync) throws ProcessException for missing executable',
    () {
      final missingCmd = Executable('this_cmd_does_not_exist_456');
      expect(
        () => missingCmd.runSync(['--version']),
        throwsA(isA<ProcessException>()),
      );
    },
  );
}
