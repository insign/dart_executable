import 'dart:io';

import 'package:process_run/which.dart';

/// A class for dealing with executables.
class Executable {
  final String cmd;
  static final _whichResults = <String, String?>{};

  /// Constructs a new `Executable` instance with the given [cmd].
  const Executable(this.cmd);

  bool get _isPath =>
      cmd.contains('/') || (Platform.isWindows && cmd.contains('\\'));

  /// Asynchronously finds the path to the executable [cmd].
  Future<String?> find({bool ignoreCache = false}) async {
    if (!ignoreCache && _whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }

    String? result;
    if (_isPath) {
      final file = File(cmd);
      if (await file.exists()) {
        if (Platform.isWindows) {
          if (_isWindowsExecutable(cmd)) result = file.absolute.path;
        } else {
          if (await _isPosixExecutable(file)) result = file.absolute.path;
        }
      }
    }

    result ??= await which(cmd);

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

    String? result;
    if (_isPath) {
      final file = File(cmd);
      if (file.existsSync()) {
        if (Platform.isWindows) {
          if (_isWindowsExecutable(cmd)) result = file.absolute.path;
        } else {
          if (_isPosixExecutableSync(file)) result = file.absolute.path;
        }
      }
    }

    result ??= whichSync(cmd);

    _whichResults[cmd] = result;
    return result;
  }

  /// Synchronously checks if the executable [cmd] exists.
  bool existsSync({bool ignoreCache = false}) =>
      findSync(ignoreCache: ignoreCache) != null;

  bool _isWindowsExecutable(String path) {
    // PATHEXT defaults to .COM;.EXE;.BAT;.CMD;.VBS;.VBE;.JS;.JSE;.WSF;.WSH;.MSC
    final pathExt = Platform.environment['PATHEXT'] ?? '.EXE;.BAT;.CMD;.COM';
    final exts = pathExt.split(';').where((e) => e.isNotEmpty).toList();
    final upperPath = path.toUpperCase();
    return exts.any((ext) => upperPath.endsWith(ext.toUpperCase()));
  }

  Future<bool> _isPosixExecutable(File file) async {
    final stat = await file.stat();
    // 0x1 (other x) | 0x8 (group x) | 0x40 (owner x) -> 0x49
    return (stat.mode & 0x49) != 0;
  }

  bool _isPosixExecutableSync(File file) {
    final stat = file.statSync();
    return (stat.mode & 0x49) != 0;
  }
}
