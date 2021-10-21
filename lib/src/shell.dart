import 'dart:io';

import 'package:rucksack/rucksack.dart';
import 'package:logging/logging.dart';
import 'package:process_run/shell.dart' as pr;

// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart' show scriptToCommands;

final log = Logger('cf:Shell');

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
  IShell copyWith({bool? verbose, bool? color});
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

typedef ShellFn<IShell> = void Function(IShell a);

/// Takes a [IShell], and produces a copy with the specified configuration.
/// Then invokes the [func] with the [IShell] copy
///
/// `since 0.0.1`
withShellOptions(
  IShell shell,
  Future<void> Function(IShell) func, {
  bool? verbose = false,
  bool? color = false,
}) async {
  final IShell clone = shell.copyWith(verbose: verbose, color: color);
  await func(clone);
}

/// A Basic implementation of [IShell] using [package:process_run]
///
/// `since 0.0.1`
class ProcessRunShell implements IShell {
  final bool verbose;
  final bool color;

  ProcessRunShell({
    this.verbose = false,
    this.color = false,
  });

  @override
  Future<ProcessResult> run(
    String script, {
    Map<String, String>? environment = null,
  }) async {
    _requireSingleCommand(script);
    log.info('Running: $script');
    var result = await pr.run(
      script,
      verbose: verbose,
      environment: environment,
    );
    return result.first;
  }

  @override
  String? which(String cmd) {
    _requireSingleCommand(cmd);
    return pr.whichSync(cmd);
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
    log.fine('Validating command exists: $command');
    _requireSingleCommand(command);
    if (isFalse(hasCommand(command))) {
      throw CommandNotFoundException(command);
    }
  }

  @override
  IShell copyWith({bool? verbose, bool? color}) {
    return ProcessRunShell(
      verbose: verbose ?? this.verbose,
      color: color ?? this.color,
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
    log.warning(
        '`$command` not found. Please check your \$PATH and environment');
  }
  return hasCommand;
}
