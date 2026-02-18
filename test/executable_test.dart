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

  test('Test executable find with ignoreCache', () async {
    final ls = Executable('ls');
    final result = await ls.find(ignoreCache: true);
    expect(result, isNotNull);
  });

  test('Test executable exists with ignoreCache', () async {
    final ls = Executable('ls');
    final result = await ls.exists(ignoreCache: true);
    expect(result, true);
  });

  test('Test executable findSync with ignoreCache', () {
    final ls = Executable('ls');
    final result = ls.findSync(ignoreCache: true);
    expect(result, isNotNull);
  });

  test('Test executable existsSync with ignoreCache', () {
    final ls = Executable('ls');
    final result = ls.existsSync(ignoreCache: true);
    expect(result, true);
  });
}
