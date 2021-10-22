/// A collection of CLI helpers for assisting with Project focused task automation
library chassis_forge;

import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:rucksack/rucksack.dart';

import 'src/shell.dart';

export 'src/chassis_command.dart';
export 'src/shell.dart';

/// Configures Logging to the specified [level]
void configureLogger(dynamic level) {
  Level? l = cast<Level>(level);
  if (isNull(l)) {
    final bool? verbose = cast<bool>(level);
    if (isTrue(verbose)) {
      l = Level.ALL;
    }
  }
  Logger.root.level = l ?? Level.INFO;
  Logger.root.onRecord.listen((rec) {
    var level = rec.level.toString();
    level = level.padRight(7);
    var logger = rec.loggerName;
    logger = logger.substring(0, min(15, logger.length));
    print("${rec.time} | ${level} | ${logger.padRight(15)}: ${rec.message}");
  });
}

/// Registers [ProcessRunShell] as the default [IShell] implementation with [GetIt]
void registerDefaultShell(bool verbose) {
  GetIt.instance
      .registerLazySingleton<IShell>(() => ProcessRunShell(verbose: verbose));
}

extension ChassisShell on IShell {
  /// Clones the current [IShell] instance, setting the verbosity as required
  ///
  /// `since 0.0.1`
  IShell verbose({bool verbose = true}) {
    return this.copyWith(verbose: verbose);
  }

  /// Clones the current [IShell] instance, setting the color output as required
  ///
  /// `since 0.0.1`
  IShell colored({bool color = true}) {
    return this.copyWith(color: color);
  }
}
