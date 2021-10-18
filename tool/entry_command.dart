import 'dart:io';

import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:smart_arg/smart_arg.dart';

import 'analyze_command.dart';
import 'doc_command.dart';

// ignore: unused_import
import 'entry_command.reflectable.dart';
import 'format_command.dart';

@SmartArg.reflectable
@Parser(
  description: 'dart_rucksack Project Helper Tools',
)
class Args extends SmartArg {
  @BooleanArgument(short: 'v', help: 'Enable Command Verbose Mode')
  late bool verbose = false;

  @Command(help: analyzeDescription)
  late AnalyzeCommand analyze;

  @Command(help: docDescription)
  late DocCommand doc;

  @Command(help: formatDescription)
  late FormatCommand format;

  @HelpArgument()
  late bool help = false;

  late bool commandRun = false;

  @override
  void beforeCommandExecute(SmartArgCommand command) {
    configureLogger(verbose);
    registerDefaultShell(verbose);
    super.beforeCommandExecute(command);
  }

  @override
  void afterCommandExecute(SmartArgCommand command) {
    super.afterCommandExecute(command);
    commandRun = true;
  }
}

void _printUsageAndExit(Args args) {
  print(args.usage());
  exit(1);
}

void main(List<String> arguments) {
  initializeReflectable();
  var args = Args()..parse(arguments);
  if (isTrue(args.help) || isFalse(args.commandRun)) {
    _printUsageAndExit(args);
  }
}
