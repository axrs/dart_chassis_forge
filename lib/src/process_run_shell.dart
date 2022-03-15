import 'dart:async';
import 'dart:io';

import 'package:chassis_forge/src/exceptions.dart';
import 'package:logging/logging.dart';
import 'package:process_run/shell.dart' as pr;
// ignore: implementation_imports
import 'package:process_run/src/shell_utils.dart' show scriptToCommands;

import 'ishell.dart';
import 'util.dart';

final _log = Logger('cf:Shell');

bool _isBlank(String? v) {
  return v == null || v.trim().isEmpty;
}

void _requireCommand(String command) {
  if (_isBlank(command)) {
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

Future<List<ProcessResult>> _prRun(
  String script, {
  bool verbose = false,
  Map<String, String>? environment,
  String? workingDirectory,
  bool throwOnError = true,
  Stream<List<int>>? stdin,
  StreamSink<List<int>>? stdout,
}) {
  return pr.run(
    script,
    verbose: verbose,
    environment: environment,
    workingDirectory: workingDirectory,
    throwOnError: throwOnError,
    stdin: stdin,
    stdout: stdout,
    onProcess: (proc) {
      if (stdin != null) {
        proc.stdin.done.catchError((err) {
          if (throwOnError) {
            throw ChassisShellException.wrap(
              'Error writing to STDIN stream',
              script,
              err,
            );
          }
        });
      }
    },
  );
}

Future<List<ProcessResult>> __prRun(
  IShell shell,
  String cmd, {
  Stream<List<int>>? stdin,
  StreamSink<List<int>>? stdout,
}) {
  return _prRun(
    cmd,
    verbose: shell.isVerbose(),
    environment: shell.environment(),
    workingDirectory: shell.workingDirectory(),
    throwOnError: shell.throwsOnError(),
    stdin: stdin,
    stdout: stdout,
  );
}

class _PreviousPipe {
  final StreamController<List<int>>? controller;
  final Future<List<ProcessResult>> process;

  _PreviousPipe(this.process, this.controller);
}

class ShellCommandBuilder extends IShellCommandBuilder {
  final IShell _shell;
  final List<String> _commands;

  ShellCommandBuilder._(IShell shell, String cmd)
      : _shell = shell,
        _commands = [cmd];

  ShellCommandBuilder.__(IShell shell, List<String> commands)
      : _shell = shell,
        _commands = commands;

  @override
  IShellCommandBuilder pipe(
    String cmd, [
    List<String>? args,
  ]) {
    return ShellCommandBuilder.__(_shell, [
      ..._commands,
      buildCmdWithArgs(cmd, args),
    ]);
  }

  @override
  Future<ProcessResult> run([Stdout? stdout]) async {
    _commands.forEach(_requireSingleCommand);
    if (1 == _commands.length) {
      return _shell.run(_commands.first, stdout: stdout);
    } else {
      // TODO There is an issue at the moment catching a stream closing error.
      // this occurs when a previous processes stdout is fed to the next stdin
      // but the next is shutting down or is closed.
      var shell = _shell.copyWith(throwOnError: false);
      // ignore: omit_local_variable_types
      List<_PreviousPipe> pipes = _commands.fold([], (procs, command) {
        var prev = procs.isNotEmpty ? procs.last : null;
        var controller = (procs.length == _commands.length - 1)
            ? null
            : StreamController<List<int>>();
        var process = __prRun(
          shell,
          command,
          stdin: prev?.controller?.stream,
          stdout: controller?.sink ?? stdout,
        )..whenComplete(() async {
            await controller?.close();
          });
        return procs..add(_PreviousPipe(process, controller));
      });

      var results = (await Future.wait(
        pipes.map((e) async {
          return (await e.process).first;
        }).toList(),
      ))
          .map<ProcessResult>(
        (v) {
          return ProcessResult(
            v.pid,
            v.exitCode,
            tryTrimRight(v.stdout),
            tryTrimRight(v.stderr),
          );
        },
      ).toList();
      if (_shell.throwsOnError() && results.any(_nonZeroExitCode)) {
        var firstError = results.firstWhere(_nonZeroExitCode);
        var res = PipedProcessResult(results, firstError);
        throw PipedCommandResultException(
          firstError.stdout,
          res,
          _commands.join(' | '),
        );
      } else {
        return PipedProcessResult(results, results.last);
      }
    }
  }
}

bool _nonZeroExitCode(ProcessResult p) {
  return p.exitCode != 0;
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
    Stream<List<int>>? stdin,
    StreamSink<List<int>>? stdout,
    List<String>? args,
  }) async {
    _requireSingleCommand(script);
    var cmd = buildCmdWithArgs(script, args);
    _log.fine('Running: $cmd');
    ProcessResult res;
    try {
      var result = await _prRun(
        cmd,
        verbose: _verbose,
        environment: environment ?? _environment,
        workingDirectory: _workingDirectory,
        stdout: stdout,
        stdin: stdin,
      );
      res = result.first;
    } on pr.ShellException catch (ex) {
      if (!_throwOnError && ex.result != null) {
        res = ex.result!;
      } else {
        throw ChassisShellException(ex.message, ex.result, cmd);
      }
    }
    return ProcessResult(
      res.pid,
      res.exitCode,
      tryTrimRight(res.stdout),
      tryTrimRight(res.stderr),
    );
  }

  @override
  ShellCommandBuilder cmd(String script) {
    return ShellCommandBuilder._(this, script);
  }

  static final Map<String, String?> _whichCache = <String, String?>{};

  @override
  String? which(String cmd) {
    _requireSingleCommand(cmd);
    return _whichCache.computeIfNull(cmd, pr.whichSync);
  }

  @override
  bool hasCommand(String command) {
    return which(command) != null;
  }

  @override
  bool supportsColorOutput() {
    return _color;
  }

  @override
  void requireCommand(String command) {
    _log.fine('Validating command exists: $command');
    _requireSingleCommand(command);
    if (!hasCommand(command)) {
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
  if (!hasCommand) {
    _log.warning(
      '`$command` not found. Please check your \$PATH and environment',
    );
  }
  return hasCommand;
}
