import 'dart:io';

import 'package:chassis_forge/src/shell.dart';
import 'package:logging/logging.dart';
import 'package:rucksack/rucksack.dart';

final _log = Logger('cf:Dart');

/// True if the current Shell has a reference to `dart`
///
/// `since 0.0.1`
bool hasCli(IShell shell) => hasCommand(shell, 'dart');

/// True if the current Shell does not have a reference to `dart`
///
/// `since 0.0.1`
bool isMissingCli(IShell shell) => isFalse(hasCli(shell));

String _pubspecFile = 'pubspec.yaml';
String _buildSpecFile = 'pubspec.yaml';

late bool _hasBuildSpec = File(_buildSpecFile).existsSync();
late bool _hasPubspec = File(_pubspecFile).existsSync();

/// True if the current folder contains a 'pubspec.yaml' file.
///
/// `since 0.0.1`
bool isProject(IShell shell) => _hasPubspec;

/// True if the current folder contains a 'build.yaml' file.
///
/// `since 0.0.1`
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
/// `since 0.0.1`
Future<void> format(IShell shell) async {
  await _whenDartProject('Format', shell, () async {
    _log.info('Formatting Source Files...');
    await shell.run('dart format --fix .');
  });
}

/// Installs dependencies for the current dart project
///
/// `since 0.0.1`
Future<void> installDependencies(IShell shell, {bool upgrade = false}) async {
  await _whenDartProject('Install Dependencies', shell, () async {
    _log.info('Installing Dependencies...');
    await shell.run(upgrade ? 'dart pub upgrade' : 'dart pub get');
  });
}

/// Analyzes the Dart source files for the current dart project
///
/// `since 0.0.1`
Future<void> analyze(IShell shell) async {
  await _whenDartProject('Analyze', shell, () async {
    _log.info('Analyzing...');
    await shell.run('dart analyze');
  });
}

/// Unit Tests the Dart source files for the current dart project
///
/// `since 0.0.1`
Future<void> test(IShell shell) async {
  await _whenDartProject('Unit Test', shell, () async {
    _log.info('Unit Testing...');
    var extraFlags = shell.supportsColorOutput() ? '--color' : '';
    await shell.run('dart test $extraFlags'.trim());
  });
}

/// Builds the Dart source files for the current dart project
///
/// `since 0.0.1`
Future<void> build(IShell shell, [String? config]) async {
  await _whenDartBuildable('Build', shell, () async {
    _log.info('Building $config'.trim());
    final String configFlag = config != null ? '--config $config' : '';
    await shell.run('''
        dart run build_runner build \\
          --delete-conflicting-outputs \\
          $configFlag
        '''
        .trim());
  });
}

/// Compiles the specified [dartFile] into the target [executableType]
///
/// `since 0.0.1`
Future<void> compile(
  IShell shell,
  String dartFile, [
  String executableType = 'kernel',
]) async {
  await _whenDartBuildable('Compile', shell, () async {
    _log.info('Compiling $dartFile to $executableType');
    await shell.run('dart compile $executableType $dartFile');
  });
}

/// Generates HTML documentation for the Dart Project into the specified [output]
/// directory in the given [format]
///
/// [format] can be either `md` or `html`
///
/// `since 0.0.1`
Future<void> doc(
  IShell shell, {
  String output = "doc",
  String format = "html",
}) async {
  await _whenDartProject('Doc', shell, () async {
    _log.info('Building Documentation...');
    shell.requireCommand('dartdoc');
    await shell.run('dartdoc --output $output --format $format');
  });
}
