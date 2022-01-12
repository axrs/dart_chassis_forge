/// A collection of CLI helpers for assisting with Project focused task automation
library chassis_forge;

import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:rucksack/rucksack.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'src/shell.dart';

export 'src/shell.dart';

/// Configures Logging to the specified [level]
void configureLogger(dynamic level) {
  var l = cast<Level>(level);
  if (isNull(l)) {
    var verbose = cast<bool>(level);
    if (isTrue(verbose)) {
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
}

abstract class HelpOption {
  abstract bool help;
}

abstract class VerboseOption {
  abstract bool verbose;
}

/// Chassis Command Boilerplate extends [SmartArgCommand] to print usage if
/// requested. Otherwise, invokes [run] with [IShell] obtained from the global
/// [GetIt] instance and parent [SmartArg] arguments.
abstract class ChassisCommand extends SmartArgCommand {
  @override
  Future<void> execute(SmartArg parentArguments) async {
    var showHelp = cast<HelpOption>(this)?.help;
    if (isTrue(showHelp)) {
      print(usage());
      exit(1);
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

/// Gets the Shell instance for the current context
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

class ChassisForge extends SmartArg {
  late bool commandRun = false;
  late bool loggingConfigured = false;
  late bool _verbose = false;
  String? _workingDirectory;
  late final IShell _shell = ProcessRunShell(
    verbose: _verbose,
    workingDirectory: _workingDirectory,
  );

  @override
  void beforeCommandExecute(SmartArgCommand command) {
    _verbose = cast<VerboseOption>(this)?.verbose ?? false;
    if (!loggingConfigured) {
      configureLogger(_verbose);
    }
    super.beforeCommandExecute(command);
  }

  @override
  void afterCommandExecute(SmartArgCommand command) {
    super.afterCommandExecute(command);
    commandRun = true;
  }

  void setLogLevel(dynamic level) {
    configureLogger(level);
    loggingConfigured = true;
  }

  void setWorkingDirectory(String workingDirectory) {
    _workingDirectory = workingDirectory;
  }

  void runWith(List<String> arguments) {
    parse(arguments);

    var help = cast<HelpOption>(this)?.help;
    if (isTrue(help) || isFalse(commandRun)) {
      print(usage());
      exit(1);
    }
  }
}
