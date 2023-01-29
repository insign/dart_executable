The executable package is a simple Dart library for dealing with executables. It provides a class called Executable which makes it easy to find the path to an executable and check if it exists on the system.

## Getting started

```dart
dart pub add executable
```
## Usage

```dart
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
```

## LICENSE

[BSD 3-Clause License](./LICENSE)

## CONTRIBUTE
We welcome contributions to the `executable` package. If you have an idea for a new feature or have found a bug, just do a pull request (PR).
