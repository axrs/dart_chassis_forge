import 'dart:io';

import 'package:process_run/shell.dart' as pr;

import 'ishell.dart';
import 'util.dart';

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
  final Exception? reason;

  ChassisShellException(String message, ProcessResult? result, this.command)
      : reason = null,
        super(message, result);

  ChassisShellException.wrap(String message, this.command, this.reason)
      : super(message, null);

  @override
  String toString() {
    return [
      'ChassisShellException executing: $command',
      message,
      if (result != null) ...[
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

/// Exception thrown when any piped process exists with a non-zero exit code
///
/// `since 2.2.0`
class PipedCommandResultException extends ChassisShellException {
  final PipedProcessResult results;

  PipedCommandResultException(
    String message,
    this.results,
    String command,
  ) : super(message, results.pipeResults.last, command);

  @override
  String toString() {
    return [
      'PipedCommandResultException executing: $command',
      message,
      if (result != null) ...[
        tryTrimRight(result!.stdout),
        '-----',
        tryTrimRight(result!.stderr),
        '-----',
      ],
    ].join('\n');
  }
}
