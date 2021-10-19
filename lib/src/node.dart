import 'dart:io';

import 'package:dart_chassis_forge/src/shell.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:logging/logging.dart';

final _log = Logger('cf:node');

String _packageJson = 'package.json';

/// True if the current Shell has a reference to `npm`
///
/// `since 0.0.1`
bool hasNpm(IShell shell) => hasCommand(shell, 'npm');

/// True if the current Shell does not have a reference to `npm`
///
/// `since 0.0.1`
bool isMissingNpm(IShell shell) => isFalse(hasNpm(shell));

/// True if the current Shell has a reference to `npx`
///
/// `since 0.0.1`
bool hasNpx(IShell shell) => hasCommand(shell, 'npx');

/// True if the current Shell does not have a reference to `npx`
///
/// `since 0.0.1`
bool isMissingNpx(IShell shell) => isFalse(hasNpx(shell));

/// True if the current folder contains a 'package.json' file.
///
/// `since 0.0.1`
late bool isProject = File(_packageJson).existsSync();

_whenNodeProject(
  String action,
  IShell shell,
  dynamic f,
) async {
  if (isProject) {
    await f();
  } else {
    _log.fine('Skipping $action. No $_packageJson found.');
  }
}

/// Unit Tests the source files for the current Node project
///
/// `since 0.0.1`
Future<void> test(IShell shell) async {
  _whenNodeProject('Unit Test', shell, () async {
    _log.info('Unit Testing...');
    await shell.run('npm test');
  });
}

/// Installs dependencies for the current Node project
///
/// `since 0.0.1`
Future<void> installDependencies(
  IShell shell, {
  bool installForCi = false,
}) async {
  _whenNodeProject('Install Dependencies', shell, () async {
    if (installForCi) {
      _log.info('Installing CI Dependencies...');
      await shell.run('npm ci');
    } else {
      _log.info('Installing Dependencies...');
      await shell.run('npm install');
    }
  });
}

/// Runs the specified npx [command]
///
/// Throws [CommandNotFoundException] if `npx` is not found
///
/// `since 0.0.1`
Future<void> npx(IShell shell, String command) async {
  shell.requireCommand('npx');
  _log.info('Running NPX command...');
  await shell.run('npx $command');
}

/// Runs the specified npm [command]
///
/// Throws [CommandNotFoundException] if `npm` is not found
///
/// `since 0.0.1`
Future<void> npm(IShell shell, String command) async {
  shell.requireCommand('npm');
  _log.info('Running NPM command...');
  await shell.run('npm $command');
}

/// Runs the specified npm [command]
///
/// Throws [CommandNotFoundException] if `npm` is not found
///
/// `since 0.0.1`
Future<void> node(IShell shell, String command) async {
  shell.requireCommand('node');
  _log.info('Running Node command...');
  await shell.run('node $command');
}

/// Runs the current npm version
///
/// Throws [CommandNotFoundException] if `npm` is not found
///
/// `since 0.0.1`
Future<String?> npmVersion(IShell shell) async {
  shell.requireCommand('npm');
  final String? version =
      cast<String>((await shell.run('npm --version')).stdout);
  return version?.trim();
}

/// Runs the current node version
///
/// Throws [CommandNotFoundException] if `node` is not found
///
/// `since 0.0.1`
Future<String?> nodeVersion(IShell shell) async {
  shell.requireCommand('node');
  final String? version =
      cast<String>((await shell.run('node --version')).stdout);
  return version?.trim().replaceAll(RegExp(r"^v"), "");
}

/// Runs the current npx version
///
/// Throws [CommandNotFoundException] if `npx` is not found
///
/// `since 0.0.1`
Future<String?> npxVersion(IShell shell) async {
  shell.requireCommand('npx');
  final String? version =
      cast<String>((await shell.run('npx --version')).stdout);
  return version?.trim();
}
