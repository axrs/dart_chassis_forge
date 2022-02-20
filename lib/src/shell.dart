import 'dart:io';

import 'package:logging/logging.dart';
import 'package:process_run/shell.dart' as pr;
// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart' show scriptToCommands;
import 'package:rucksack/rucksack.dart';

import 'util.dart';

final _log = Logger('cf:Shell');

/// A marker interface representing a basic Shell to run and evaluate commands
///
/// `since 0.0.1`
abstract class IShell {
  /// True if the shell implementation supports color output
  ///
  /// `since 0.0.1`
  bool supportsColorOutput();

  /// True if the shell implementation throws an exception on error
  ///
  /// `since 2.1.0`
  bool throwsOnError();

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
  IShell copyWith({
    bool? verbose,
    bool? color,
    String? workingDirectory,
    bool? throwOnError,
    Map<String, String>? environment,
  });

  /// Returns the current working directory
  ///
  /// `since 0.0.1`
  String workingDirectory();

  /// Returns the current environment
  ///
  /// `since 0.3.0`
  Map<String, String> environment();

  /// Returns true if the current instance is verbose
  ///
  /// `since 2.0.0`
  bool isVerbose();
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

/// Exception thrown when a Command is not found within the $PATH
///
/// `since 1.1.0`
class ChassisShellException extends pr.ShellException {
  final String command;

  ChassisShellException(String message, ProcessResult? result, this.command)
      : super(message, result);

  @override
  String toString() {
    return [
      'ChassisShellException executing: $command',
      message,
      if (isNotNull(result)) ...[
        tryTrimRight(result!.stdout),
        '-----',
        tryTrimRight(result!.stderr),
        '-----',
      ],
    ].join('\n');
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

/// A Basic implementation of [IShell] using [package:process_run]
///
/// `since 0.0.1`
class ProcessRunShell implements IShell {
  final bool _verbose;
  final bool _color;
  final bool _throwOnError;
  final String _workingDirectory;
  final Map<String, String> _environment;

  ProcessRunShell({
    verbose = false,
    color = false,
    String? workingDirectory,
    Map<String, String>? environment,
    bool? throwOnError,
  })  : _color = color,
        _verbose = verbose,
        _workingDirectory = workingDirectory ?? Directory.current.path,
        _environment = environment ?? Platform.environment,
        _throwOnError = throwOnError ?? true;

  @override
  Future<ProcessResult> run(
    String script, {
    Map<String, String>? environment,
  }) async {
    _requireSingleCommand(script);
    _log.fine('Running: $script');
    ProcessResult res;
    try {
      var result = await pr.run(
        script,
        verbose: _verbose,
        environment: environment ?? _environment,
        workingDirectory: _workingDirectory,
      );
      res = result.first;
    } on pr.ShellException catch (ex) {
      if (isFalse(_throwOnError) && isNotNull(ex.result)) {
        res = ex.result!;
      } else {
        throw ChassisShellException(ex.message, ex.result, script);
      }
    }
    return ProcessResult(
      res.pid,
      res.exitCode,
      tryTrimRight(res.stdout),
      tryTrimRight(res.stderr),
    );
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
    return _color;
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
  IShell copyWith({
    bool? verbose,
    bool? color,
    String? workingDirectory,
    Map<String, String>? environment,
    bool? throwOnError,
  }) {
    return ProcessRunShell(
      verbose: verbose ?? _verbose,
      color: color ?? _color,
      workingDirectory: workingDirectory ?? _workingDirectory,
      environment: environment ?? _environment,
      throwOnError: throwOnError ?? _throwOnError,
    );
  }

  @override
  String workingDirectory() {
    return _workingDirectory;
  }

  @override
  Map<String, String> environment() {
    return _environment;
  }

  @override
  bool isVerbose() {
    return _verbose;
  }

  @override
  bool throwsOnError() {
    return _throwOnError;
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
      '`$command` not found. Please check your \$PATH and environment',
    );
  }
  return hasCommand;
}
