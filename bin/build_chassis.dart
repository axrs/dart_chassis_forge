import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as dart;

bool _isDartFile(final FileSystemEntity file) {
  return file.path.endsWith('.dart');
}

bool _isReflectable(final FileSystemEntity file) {
  return file.path.endsWith('reflectable.dart');
}

String _rootName(final FileSystemEntity file) {
  return file.path.split(RegExp(r"\.")).first;
}

bool _isModifiedAfter(
  final FileSystemEntity left,
  final FileSystemEntity right,
) {
  return left.statSync().modified.isBefore(right.statSync().modified);
}

void _deleteSync(FileSystemEntity e) {
  e.deleteSync();
}

Future<void> main(List<String> args) async {
  Directory dir = Directory(args.first);
  var rebuildRequired = false;
  var files = dir.listSync(recursive: false).where(_isDartFile);
  groupBy(files, _rootName).forEach((key, value) {
    if (value.length != 2 || !_isModifiedAfter(value.first, value.last)) {
      rebuildRequired = true;
    }
  });
  var shell = ProcessRunShell();
  //TODO Move into dart
  if (!File('pubspec.lock').existsSync()) {
    await dart.installDependencies(shell);
  }
  if (rebuildRequired) {
    files.where(_isReflectable).forEach(_deleteSync);
    await dart.buildChassis(shell);
  }
}
