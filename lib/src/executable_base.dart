import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:process_run/which.dart';

/// A class for dealing with executables.
class Executable {
  final String cmd;
  static final _whichResults = <String, String?>{};

  /// Constructs a new `Executable` instance with the given [cmd].
  const Executable(this.cmd);

  bool get _isPath =>
      cmd.contains('/') || (Platform.isWindows && cmd.contains('\\'));

  String _getCacheKey(String? workingDirectory) {
    if (_isPath && !p.isAbsolute(cmd)) {
      return p.join(workingDirectory ?? Directory.current.path, cmd);
    }
    return cmd;
  }

  /// Asynchronously finds the path to the executable [cmd].
  Future<String?> find({
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
  }) async {
    final shouldIgnoreCache =
        ignoreCache ||
        environment != null ||
        workingDirectory != null ||
        !includeParentEnvironment;

    final cacheKey = _getCacheKey(workingDirectory);

    if (!shouldIgnoreCache && _whichResults.containsKey(cacheKey)) {
      return _whichResults[cacheKey];
    }

    String? result;
    if (_isPath) {
      final filePath = workingDirectory != null
          ? p.join(workingDirectory, cmd)
          : cmd;
      final file = File(filePath);
      if (await file.exists()) {
        if (Platform.isWindows) {
          if (_isWindowsExecutable(cmd)) {
            result = file.absolute.path;
          }
        } else if (await _isPosixExecutable(file)) {
          result = file.absolute.path;
        }
      }
    }

    result ??= await which(
      cmd,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );

    if (!shouldIgnoreCache) {
      _whichResults[cacheKey] = result;
    }
    return result;
  }

  /// Asynchronously checks if the executable [cmd] exists.
  Future<bool> exists({
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
  }) async =>
      await find(
        ignoreCache: ignoreCache,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
      ) !=
      null;

  /// Synchronously finds the path to the executable [cmd].
  String? findSync({
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
  }) {
    final shouldIgnoreCache =
        ignoreCache ||
        environment != null ||
        workingDirectory != null ||
        !includeParentEnvironment;

    final cacheKey = _getCacheKey(workingDirectory);

    if (!shouldIgnoreCache && _whichResults.containsKey(cacheKey)) {
      return _whichResults[cacheKey];
    }

    String? result;
    if (_isPath) {
      final filePath = workingDirectory != null
          ? p.join(workingDirectory, cmd)
          : cmd;
      final file = File(filePath);
      if (file.existsSync()) {
        if (Platform.isWindows) {
          if (_isWindowsExecutable(cmd)) {
            result = file.absolute.path;
          }
        } else if (_isPosixExecutableSync(file)) {
          result = file.absolute.path;
        }
      }
    }

    result ??= whichSync(
      cmd,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );

    if (!shouldIgnoreCache) {
      _whichResults[cacheKey] = result;
    }
    return result;
  }

  /// Synchronously checks if the executable [cmd] exists.
  bool existsSync({
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
  }) =>
      findSync(
        ignoreCache: ignoreCache,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
      ) !=
      null;

  /// Asynchronously starts the executable with the given [arguments].
  Future<Process> start(
    List<String> arguments, {
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final path = await find(
      ignoreCache: ignoreCache,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );
    if (path == null) {
      throw ProcessException(cmd, arguments, 'Executable not found.');
    }

    return Process.start(
      path,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
  }

  /// Asynchronously runs the executable with the given [arguments].
  Future<ProcessResult> run(
    List<String> arguments, {
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) async {
    final path = await find(
      ignoreCache: ignoreCache,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );
    if (path == null) {
      throw ProcessException(cmd, arguments, 'Executable not found.');
    }

    return Process.run(
      path,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }

  /// Synchronously runs the executable with the given [arguments].
  ProcessResult runSync(
    List<String> arguments, {
    bool ignoreCache = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    final path = findSync(
      ignoreCache: ignoreCache,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
    );
    if (path == null) {
      throw ProcessException(cmd, arguments, 'Executable not found.');
    }

    return Process.runSync(
      path,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );
  }

  bool _isWindowsExecutable(String path) {
    final pathExt = Platform.environment['PATHEXT'] ?? '.EXE;.BAT;.CMD;.COM';
    final extensions = pathExt.split(';').where((ext) => ext.isNotEmpty);
    final upperPath = path.toUpperCase();
    return extensions.any((ext) => upperPath.endsWith(ext.toUpperCase()));
  }

  Future<bool> _isPosixExecutable(File file) async {
    final stat = await file.stat();
    return (stat.mode & 0x49) != 0;
  }

  bool _isPosixExecutableSync(File file) {
    final stat = file.statSync();
    return (stat.mode & 0x49) != 0;
  }
}
