import 'package:process_run/which.dart';

/// A class for dealing with executables.
class Executable {
  final String cmd;
  static final _whichResults = <String, String?>{};

  /// Constructs a new `Executable` instance with the given [cmd].
  const Executable(this.cmd);

  /// Asynchronously finds the path to the executable [cmd].
  Future<String?> find({bool ignoreCache = false}) async {
    if (!ignoreCache && _whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = await which(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  /// Asynchronously checks if the executable [cmd] exists.
  Future<bool> exists({bool ignoreCache = false}) async =>
      await find(ignoreCache: ignoreCache) != null;

  /// Synchronously finds the path to the executable [cmd].
  String? findSync({bool ignoreCache = false}) {
    if (!ignoreCache && _whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = whichSync(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  /// Synchronously checks if the executable [cmd] exists.
  bool existsSync({bool ignoreCache = false}) =>
      findSync(ignoreCache: ignoreCache) != null;
}
