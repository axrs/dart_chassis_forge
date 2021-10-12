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

String _pubspecFile = 'pubspec.yaml';
String _buildSpecFile = 'pubspec.yaml';

late bool _hasBuildSpec = File(_buildSpecFile).existsSync();
late bool _hasPubspec = File(_pubspecFile).existsSync();

/// True if the current folder contains a 'pubspec.yaml' file.
///
/// {@since 0.0.1}
bool isProject(IShell shell) => _hasPubspec;

/// True if the current folder contains a 'build.yaml' file.
///
/// {@since 0.0.1}
bool isBuildable(IShell shell) => _hasBuildSpec;

_whenDartProject(String action, IShell shell, dynamic f) async {
  if (isProject(shell)) {
    await f();
  } else {
    _log.fine('Skipping $action. No $_pubspecFile found.');
  }
}

_whenDartBuildable(String action, IShell shell, dynamic f) async {
  if (isBuildable(shell)) {
    await f();
  } else {
    _log.fine('Skipping $action. No $_buildSpecFile found.');
  }
}

/// Formats all Dart source files in the current directory using the Dart CLI
///
/// {@since 0.0.1}
Future<void> format(IShell shell) async {
  _whenDartProject('Format', shell, () async {
    logging.section(_log, 'Formatting Source Files');
    await shell.run('dart format --fix .');
  });
}

/// Installs dependencies for the current dart project
///
/// {@since 0.0.1}
Future<void> installDependencies(IShell shell) async {
  _whenDartProject('Install Dependencies', shell, () async {
    logging.section(_log, 'Installing Dependencies');
    await shell.run('dart pub get');
  });
}

/// Analyzes the Dart source files for the current dart project
///
/// {@since 0.0.1}
Future<void> analyze(IShell shell) async {
  _whenDartProject('Analyze', shell, () async {
    logging.section(_log, 'Analyzing');
    await shell.run('dart pub get');
  });
}

/// Unit Tests the Dart source files for the current dart project
///
/// {@since 0.0.1}
Future<void> test(IShell shell) async {
  _whenDartProject('Unit Test', shell, () async {
    logging.section(_log, 'Unit Testing');
    var extraFlags = shell.supportsColorOutput() ? '--color' : '';
    await shell.run('dart test $extraFlags'.trim());
  });
}

/// Builds the Dart source files for the current dart project
///
/// {@since 0.0.1}
Future<void> build(IShell shell) async {
  _whenDartBuildable('Build', shell, () async {
    logging.section(_log, 'Building');
    await shell.run('dart run build_runner build --delete-conflicting-outputs');
  });
}

/// Builds the Dart source files for the current dart project
///
/// {@since 0.0.1}
Future<void> buildChassis(IShell shell) async {
  if (File('build.chassis.yaml').existsSync()) {
    logging.section(_log, 'Building Chassis');
    await shell.run('''
dart run build_runner build \\
  --config build.chassis.yaml \\
  --delete-conflicting-outputs
''');
  } else {
    _log.fine('Skipping Chassis Build. No build.chassis.yaml found.');
  }
}
