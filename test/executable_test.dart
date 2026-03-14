import 'dart:io';

import 'package:executable/executable.dart';
import 'package:test/test.dart';

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
    final ls = Executable('ls');
    final result = await ls.run(['-l']);
    expect(result.exitCode, 0);
  });

  test('Test executable run async failure', () async {
    final inexistent = Executable('inexistent_executable_xyz');
    expect(() async => await inexistent.run([]), throwsA(isA<ProcessException>()));
  });

  test('Test executable runSync', () {
    final ls = Executable('ls');
    final result = ls.runSync(['-l']);
    expect(result.exitCode, 0);
  });

  test('Test executable runSync failure', () {
    final inexistent = Executable('inexistent_executable_xyz');
    expect(() => inexistent.runSync([]), throwsA(isA<ProcessException>()));
  });
}
