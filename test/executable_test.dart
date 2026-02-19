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

  test('Test executable existence with ignoreCache', () async {
    final ls = Executable('ls');
    final result = await ls.exists(ignoreCache: true);
    expect(result, true);
  });

  test('Test executable path with ignoreCache', () async {
    final ls = Executable('ls');
    final result = await ls.find(ignoreCache: true);
    expect(result, isNotNull);
  });

  test('Test sync executable existence with ignoreCache', () {
    final ls = Executable('ls');
    final result = ls.existsSync(ignoreCache: true);
    expect(result, true);
  });

  test('Test sync executable path with ignoreCache', () {
    final ls = Executable('ls');
    final result = ls.findSync(ignoreCache: true);
    expect(result, isNotNull);
  });
}
