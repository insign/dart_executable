import 'package:executable/executable.dart';

void main() {
  final cp = Executable('cp');
  if (cp.existsSync()) {
    final path = cp.findSync();
    print('The path to ${cp.cmd} executable is $path.');
  } else {
    print('The executable ${cp.cmd} was not found on your system.');
  }
}
