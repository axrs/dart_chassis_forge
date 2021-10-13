import 'package:dart_chassis_forge/src/shell.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:logging/logging.dart';

final log = Logger('cf:Node');

/// True if the current Shell has a reference to `npm`
///
/// {@since 0.0.1}
bool hasNpm(IShell shell) => hasCommand(shell, 'npm');

/// True if the current Shell does not have a reference to `npm`
///
/// {@since 0.0.1}
bool isMissingNpm(IShell shell) => isFalse(hasNpm(shell));

/// True if the current Shell has a reference to `npx`
///
/// {@since 0.0.1}
bool hasNpx(IShell shell) => hasCommand(shell, 'npx');

/// True if the current Shell does not have a reference to `npx`
///
/// {@since 0.0.1}
bool isMissingNpx(IShell shell) => isFalse(hasNpx(shell));
