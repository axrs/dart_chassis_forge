import 'dart:io';

import 'package:chassis_forge/src/exceptions.dart';
import 'package:logging/logging.dart';
import 'package:process_run/shell.dart' as pr;
// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart' show scriptToCommands;
import 'package:rucksack/rucksack.dart';

import 'shell.dart';
import 'util.dart';

final _log = Logger('cf:Shell');

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
