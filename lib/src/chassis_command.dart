import 'dart:io';

import 'package:chassis_forge/src/shell.dart';
import 'package:rucksack/rucksack.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_arg/smart_arg.dart';

/// Chassis Command Boilerplate extends [SmartArgCommand] to print usage if
/// requested. Otherwise, invokes [run] with [IShell] obtained from the global
/// [GetIt] instance and parent [SmartArg] arguments.
abstract class ChassisCommand extends SmartArgCommand {
  late bool help = false;

  @override
  Future<void> execute(SmartArg parentArguments) async {
    if (isTrue(help)) {
      print(usage());
      exit(1);
    }
    var shell = GetIt.instance<IShell>();
    await run(shell, parentArguments);
  }

  Future<void> run(final IShell shell, final SmartArg parentArguments);
}
