import 'dart:io';

import 'package:dart_chassis_forge/chassis_forge.dart' as chassis;
import 'package:dart_rucksack/rucksack.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'analyze_command.reflectable.dart';

const String analyzeDescription =
    'Runs static code analysis across the code base';

@SmartArg.reflectable
@Parser(
  description: analyzeDescription,
)
class AnalyzeCommand extends SmartArgCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> execute(SmartArg parentArguments) async {
    var shell = GetIt.instance<chassis.IShell>();
    if (isTrue(help)) {
      print(usage());
      exit(1);
    }
    await chassis.analyze(shell);
  }
}
