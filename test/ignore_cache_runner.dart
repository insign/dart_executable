import 'dart:io';
import 'package:executable/executable.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: ignore_cache_runner <cmd>');
    exit(1);
  }
  final cmd = args[0];
  final exe = Executable(cmd);

  // 1. Find the executable (should be found)
  var path = await exe.find();
  if (path == null) {
    print('Error: Executable $cmd not found initially.');
    exit(1);
  }
  print('Found at: $path');

  // 2. Delete the executable
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
    print('Deleted $path');
  } else {
    print('Error: File $path does not exist.');
    exit(1);
  }

  // 3. Find again (should be found due to cache)
  var cachedPath = await exe.find();
  if (cachedPath != path) {
    print('Error: Cache miss. Expected $path, got $cachedPath');
    exit(1);
  }
  print('Cache hit: $cachedPath');

  // 4. Find with ignoreCache: true (should NOT be found)
  var newPath = await exe.find(ignoreCache: true);
  if (newPath != null) {
    print('Error: Cache bypass failed. Expected null, got $newPath');
    exit(1);
  }
  print('Cache bypassed successfully. Result is null.');

  // Re-create file for Sync test
  await file.writeAsString('#!/bin/sh\necho hello');
  if (!Platform.isWindows) {
    await Process.run('chmod', ['+x', file.path]);
  }

  // 5. Test Sync methods
  // Note: Previous async find(ignoreCache: true) updated the cache to null!
  // So findSync() should return null if it uses the same cache.
  // Yes, _whichResults is static.

  // So we first need to re-populate cache.
  var syncPath = exe.findSync(ignoreCache: true);
  if (syncPath == null) {
    print('Error: Sync find failed after recreation.');
    exit(1);
  }

  await file.delete();

  // Sync find cache (should be hit)
  var syncCache = exe.findSync();
  if (syncCache != syncPath) {
    print('Error: Sync cache miss.');
    exit(1);
  }

  // Sync ignore cache (should be null)
  var syncIgnore = exe.findSync(ignoreCache: true);
  if (syncIgnore != null) {
    print('Error: Sync ignore cache failed.');
    exit(1);
  }

  print('All checks passed.');
}
