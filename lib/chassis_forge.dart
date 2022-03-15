/// A collection of CLI helpers for assisting with Project focused task automation
library chassis_forge;

import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';

import 'smart_arg.dart';
import 'src/ishell.dart';
import 'src/process_run_shell.dart';

export 'package:process_run/shell.dart' show shellArgument, shellArguments;

export 'src/exceptions.dart';
export 'src/ishell.dart';
export 'src/process_run_shell.dart';

T? _cast<T>(Object? x) => x is T ? x : null;

/// True if an [Logger.root.onRecord] listener has been attached
///
/// `since 1.2.2`
late bool loggingConfigured = false;

/// Configures Logging to the specified [level]
/// `since 0.0.1`
void configureLogger(dynamic level) {
  if (loggingConfigured) {
    return;
  }
  var l = _cast<Level>(level);
  if (l == null) {
    var isVerbose = _cast<bool>(level) ?? false;
    if (isVerbose) {
      l = Level.ALL;
    }
  }
  Logger.root.level = l ?? Level.INFO;
  Logger.root.onRecord.listen((LogRecord rec) {
    var level = rec.level.toString();
    level = level.padRight(7);
    var logger = rec.loggerName;
    logger = logger.substring(0, min(15, logger.length));
    print(
      '${rec.time.toString().padRight(26)} | $level | ${logger.padRight(15)}: ${rec.message}',
    );
  });
  loggingConfigured = true;
}

/// A basic mixin for adding a the help argument to each [SmartArg] extension
///
/// `since 2.2.0`
@SmartArg.reflectable
mixin HelpArg {
  @HelpArgument()
  bool? help;
}

/// A basic mixin for adding a the help argument to each [SmartArg] extension
///
/// `since 2.2.0`
@SmartArg.reflectable
mixin VerboseArg {
  @BooleanArgument(
    short: 'v',
    help: 'Enable Command Verbose Mode',
  )
  late bool verbose = false;
}

/// Chassis Command Boilerplate extends [SmartArgCommand] to print usage if
/// requested. Otherwise, invokes [run] with [IShell] obtained from the global
/// [GetIt] instance and parent [SmartArg] arguments.
///
/// `since 0.0.1`
abstract class ChassisCommand extends SmartArgCommand {
  @override
  Future<void> execute(SmartArg parentArguments) async {
    var showHelp = _cast<HelpArg>(this)?.help ?? false;
    if (showHelp) {
      print(usage());
      exit(0);
    }
    var shell = getShell(this);
    await run(shell, parentArguments);
  }

  Future<void> run(IShell shell, SmartArg parentArguments) async {}
}

extension ChassisShell on IShell {
  /// Clones the current [IShell] instance, setting the verbosity as required
  ///
  /// `since 0.0.1`
  IShell verbose([bool verbose = true]) {
    return copyWith(verbose: verbose);
  }

  /// Clones the current [IShell] instance, setting the color output as required
  ///
  /// `since 0.0.1`
  IShell colored([bool color = true]) {
    return copyWith(color: color);
  }

  /// Clones the current [IShell] instance, setting the [IShell.workingDirectory]
  ///
  /// `since 0.0.1`
  IShell withWorkingDirectory(String newWorkingDirectory) {
    return copyWith(workingDirectory: newWorkingDirectory);
  }

  /// Clones the current [IShell] instance, setting the [IShell.environment]
  ///
  /// `since 0.3.0`
  IShell withEnvironment(Map<String, String> environment) {
    return copyWith(environment: environment);
  }

  /// Clones the current [IShell] instance, setting the throwOnError as required
  ///
  /// `since 1.1.0`
  IShell withThrowOnError([bool throwOnError = true]) {
    return copyWith(throwOnError: throwOnError);
  }
}

/// Gets the [IShell] instance for the current [SmartArg] context. If not found,
/// the [SmartArg.parent] will be recursively searched until a [ChassisForge]
/// instance is found.
///
/// `since 1.2.0`
IShell getShell(SmartArg context) {
  if (context is ChassisForge) {
    return context._shell;
  }
  if (context.parent != null) {
    return getShell(context.parent!);
  } else {
    throw Exception('Unable to find IShell instance in Command hierarchy');
  }
}

/// `since 0.0.1`
@SmartArg.reflectable
class ChassisForge extends SmartArg {
  /// List of arguments supplied during [runWith]. Only initialized on invocation
  /// of [runWith]
  ///
  /// `since 1.2.2`
  late List<String> arguments;

  /// True if a [Command] has been run
  late bool commandRun = false;

  late bool _isVerbose = false;
  String? _workingDirectory;

  late final IShell _shell = ProcessRunShell(
    verbose: _isVerbose,
    workingDirectory: _workingDirectory,
  );

  @override
  void afterCommandParse(SmartArg command, List<String> arguments) {
    super.afterCommandParse(command, arguments);
    _isVerbose = _cast<VerboseArg>(this)?.verbose ?? false;
    configureLogger(_isVerbose);
  }

  @override
  void afterCommandExecute(SmartArgCommand command) {
    super.afterCommandExecute(command);
    commandRun = true;
    if (parent is ChassisForge) {
      parent!.afterCommandExecute(command);
    }
  }

  void setLogLevel(dynamic level) {
    configureLogger(level);
  }

  void setWorkingDirectory(String workingDirectory) {
    _workingDirectory = workingDirectory;
  }

  /// Prints Forge usage and cleanly exits the program
  ///
  /// `since 2.0.0`
  void onHelp() {
    print(usage());
    exit(0);
  }

  /// Prints Forge usage and cleanly exits the program with code 1
  ///
  /// `since 2.0.0`
  void onUnknownCommand(List<String> arguments) {
    print('ERROR: Unknown command `${arguments.join(' ')}`');
    print(usage());
    exit(1);
  }

  @override
  Future<void> parse(List<String> arguments) async {
    await super.parse(arguments);

    var help = _cast<HelpArg>(this)?.help ?? false;
    if (help) {
      onHelp();
    } else if (!commandRun) {
      onUnknownCommand(arguments);
    }
  }

  /// Runs the [ChassisForge] with the supplied arguments.
  ///
  /// `since 0.0.1`
  Future<void> runWith(List<String> arguments) async {
    this.arguments = arguments;
    await parse(arguments);
  }
}
