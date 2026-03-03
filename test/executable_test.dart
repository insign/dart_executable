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

  test('Test run method executes successfully', () async {
    final dartExec = Executable('dart');
    final result = await dartExec.run(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test runSync method executes successfully', () {
    final dartExec = Executable('dart');
    final result = dartExec.runSync(['--version']);
    expect(result.exitCode, 0);
  });

  test('Test run throws ProcessException when not found', () async {
    final missingExec = Executable('this_should_not_exist_xyz123');
    expect(
      () => missingExec.run([]),
      throwsA(isA<Exception>()), // In dart process exception
    );
  });

  test('Test runSync throws ProcessException when not found', () {
    final missingExec = Executable('this_should_not_exist_xyz123');
    expect(() => missingExec.runSync([]), throwsA(isA<Exception>()));
  });
}
