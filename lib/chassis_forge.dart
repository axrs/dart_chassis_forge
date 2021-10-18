/// A collection of CLI helpers for assisting with Project focused task automation
library chassis_forge;

import 'dart:math';

import 'package:dart_rucksack/rucksack.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'src/dart.dart' as dart;
import 'src/markdown.dart' as markdown;
import 'src/shell.dart';

export 'src/shell.dart';

/// Formats various source code files
Future<void> format(IShell shell) async {
  await dart.format(shell);
  await markdown.format(shell);
}

/// Analyzes various source code files
Future<void> analyze(IShell shell) async {
  await dart.analyze(shell);
}

/// Runs various Source Code Unit Tests
Future<void> test(IShell shell) async {
  await dart.test(shell);
}

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
