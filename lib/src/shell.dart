import 'dart:io';

import 'exceptions.dart';

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
