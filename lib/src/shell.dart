import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart' as pr;

// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart' show scriptToCommands;
import 'package:rucksack/rucksack.dart';

final _log = Logger('cf:Shell');

/// A marker interface representing a basic Shell to run and evaluate commands
///
/// `since 0.0.1`
abstract class IShell {
  /// True if the shell implementation supports color output
  ///
  /// `since 0.0.1`
  bool supportsColorOutput();

  /// Runs a command within a IShell environment. Returning the commands
  /// result.
  /// May throw [CommandException]s.
  ///
  /// `since 0.0.1`
  Future<ProcessResult> run(
    String command, {
    Map<String, String>? environment,
  });

  /// Returns the full path location (and name) for a supplied command.
  /// Null if the command was not found.
  ///
  /// `since 0.0.1`
  String? which(String command);

  /// Returns true if the external command exists
  ///
  /// `since 0.0.1`
  bool hasCommand(String command);

  /// Throws [CommandNotFoundException] if the provided command is not present in the \$PATH
  ///
  /// `since 0.0.1`
  void requireCommand(String command);

  /// Clones the current [IShell] instance, overriding properties as specified
  ///
  /// `since 0.0.1`
  IShell copyWith({bool? verbose, bool? color, String? workingDirectory});

  /// Returns the current working directory
  ///
  /// `since 0.0.1`
  abstract String workingDirectory;
}

/// A marker interface implemented by all Command Execution exceptions
///
/// An [CommandException] is intended to convey information to the user about a
/// failure, in running external process commands which can be caught at the
/// developers discretion. They should contain useful data fields.
///
/// `since 0.0.1`
class CommandException implements Exception {}

/// Exception thrown when a Command is not found within the $PATH
///
/// `since 0.0.1`
class CommandNotFoundException implements CommandException {
  final String command;

  CommandNotFoundException(this.command);

  @override
  String toString() {
    return 'CommandNotFoundException: $command. Check your \$PATH or install the missing executable for your operating system.';
  }
}

/// Exception thrown when multiple commands to be run have been detected
///
/// `since 0.0.1`
class MultipleScriptCommandException implements CommandException {
  final String cause;
  final String command;

  MultipleScriptCommandException(this.cause, this.command);

  @override
  String toString() {
    return 'MultipleScriptCommandException: $cause\n$command';
  }
}

/// Exception thrown when no commands to run have been detected
///
/// `since 0.0.1`
class BlankCommandException implements CommandException {
  BlankCommandException();

  @override
  String toString() {
    return 'BlankCommandException: Empty, or blank command script provided';
  }
}

void _requireCommand(String command) {
  if (isBlank(command)) {
    throw BlankCommandException();
  }
}

void _requireSingleCommand(String command) {
  _requireCommand(command);
  var commandCount = scriptToCommands(command).length;
  if (commandCount != 1) {
    throw MultipleScriptCommandException(
      'Found $commandCount commands to run in script.',
      command,
    );
  }
}

typedef MapComputer<K, V> = V? Function(K key);

extension ChassisMap<K, V> on Map<K, V?> {
  /// Gets the value of the [key] from the map
  ///
  /// `since 0.0.1`
  V? get(K key) {
    return this[key];
  }

  /// Puts the [value] into the map for the given [key]
  ///
  /// `since 0.0.1`
  void put(K key, V? value) {
    this[key] = value;
  }

  /// Computes the value for the given [key] if the map does not already contain it
  ///
  /// `since 0.0.1`
  V? computeIfAbsent(K key, MapComputer<K, V?> compute) {
    if (containsKey(key)) {
      return get(key);
    } else {
      var value = compute(key);
      if (isNotNull(value)) {
        put(key, value);
      }
      return value;
    }
  }

  /// Computes the value for the given [key] if the map value is currently null
  ///
  /// `since 0.0.1`
  V? computeIfNull(K key, MapComputer<K, V?> compute) {
    var value = get(key);
    if (isNotNull(value)) {
      return value;
    } else {
      return computeIfAbsent(key, compute);
    }
  }
}

/// A Basic implementation of [IShell] using [package:process_run]
///
/// `since 0.0.1`
class ProcessRunShell implements IShell {
  bool verbose;
  bool color;
  @override
  String workingDirectory;

  ProcessRunShell({
    this.verbose = false,
    this.color = false,
    String? workingDirectory,
  }) : workingDirectory = workingDirectory ?? Directory.current.path;

  @override
  Future<ProcessResult> run(
    String script, {
    Map<String, String>? environment,
  }) async {
    _requireSingleCommand(script);
    _log.info('Running: $script');
    var result = await pr.run(
      script,
      verbose: verbose,
      environment: environment,
      workingDirectory: workingDirectory,
    );
    return result.first;
  }

  static final Map<String, String?> _whichCache = <String, String?>{};

  @override
  String? which(String cmd) {
    _requireSingleCommand(cmd);
    return _whichCache.computeIfNull(cmd, pr.whichSync);
  }

  @override
  bool hasCommand(String command) {
    return isNotNull(which(command));
  }

  @override
  bool supportsColorOutput() {
    return color;
  }

  @override
  void requireCommand(String command) {
    _log.fine('Validating command exists: $command');
    _requireSingleCommand(command);
    if (isFalse(hasCommand(command))) {
      throw CommandNotFoundException(command);
    }
  }

  @override
  IShell copyWith({bool? verbose, bool? color, String? workingDirectory}) {
    return ProcessRunShell(
      verbose: verbose ?? this.verbose,
      color: color ?? this.color,
      workingDirectory: workingDirectory ?? this.workingDirectory,
    );
  }
}

/// True if the command exists.
/// Logs a Warning if the command is not found
///
/// `since 0.0.1`
bool hasCommand(IShell shell, String command) {
  var hasCommand = shell.hasCommand(command);
  if (isFalse(hasCommand)) {
    _log.warning(
        '`$command` not found. Please check your \$PATH and environment');
  }
  return hasCommand;
}
