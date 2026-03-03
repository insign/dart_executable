import 'dart:io';

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

  /// Asynchronously runs the executable.
  Future<ProcessResult> run(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    bool ignoreCache = false,
  }) async {
    final executablePath = await find(ignoreCache: ignoreCache);
    if (executablePath == null) {
      throw ProcessException(cmd, args, 'Executable not found in path.', 2);
    }
    return Process.run(
      executablePath,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
    );
  }

  /// Synchronously runs the executable.
  ProcessResult runSync(
    List<String> args, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    bool ignoreCache = false,
  }) {
    final executablePath = findSync(ignoreCache: ignoreCache);
    if (executablePath == null) {
      throw ProcessException(cmd, args, 'Executable not found in path.', 2);
    }
    return Process.runSync(
      executablePath,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
    );
  }
}
