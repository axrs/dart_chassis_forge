import 'dart:io';

import 'package:dart_chassis_forge/src/logger.dart' as logging;
import 'package:dart_chassis_forge/src/shell.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:logging/logging.dart';

final _log = Logger('chassis_forge:Dart');

/// True if the current Shell has a reference to `dart`
///
/// {@since 0.0.1}
bool hasCli(IShell shell) => hasCommand(shell, 'dart');

/// True if the current Shell does not have a reference to `dart`
///
/// {@since 0.0.1}
bool isMissingCli(IShell shell) => isFalse(hasCli(shell));

String _packageFile = 'pubspec.yaml';

late bool _isDartProject = File(_packageFile).existsSync();

/// True if the current folder contains a 'pubspec.yaml' file.
///
/// {@since 0.0.1}
bool isDartProject(IShell shell) => _isDartProject;

_whenDartProject(String action, IShell shell, dynamic f) async {
  if (isDartProject(shell)) {
    await f();
  } else {
    _log.fine('Skipping Dart $action. No $_packageFile found.');
  }
}

/// Formats all Dart source files in the current directory using the Dart CLI
///
/// {@since 0.0.1}
Future<void> format(IShell shell) async {
  _whenDartProject('Format', shell, () async {
    logging.section(_log, 'Formatting Dart Source Files');
    await shell.run('dart format --fix .');
  });
}

/// Installs dependencies for the current dart project
///
/// {@since 0.0.1}
Future<void> installDependencies(IShell shell) async {
  _whenDartProject('Install Dependencies', shell, () async {
    logging.section(_log, 'Installing Dart Dependencies');
    await shell.run('dart pub get');
  });
}

/// Analyzes the Dart source files for the current dart project
///
/// {@since 0.0.1}
Future<void> analyze(IShell shell) async {
  _whenDartProject('Analyze', shell, () async {
    logging.section(_log, 'Installing Dart Dependencies');
    await shell.run('dart pub get');
  });
}
