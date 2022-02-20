import 'dart:io';

import 'package:process_run/shell.dart' as pr;
import 'package:rucksack/rucksack.dart';

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
