import 'dart:io';
import 'dart:mirrors';

import 'package:dart_chassis_forge/src/shell.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_arg/smart_arg.dart';

/// Chassis Command Boilerplate extends [SmartArgCommand] to print usage if
/// requested. Otherwise, invokes [run] with [IShell] obtained from the global
/// [GetIt] instance and parent [SmartArg] arguments.
class ChassisCommand extends SmartArgCommand {
  @override
  Future<void> execute(SmartArg parentArguments) async {
    final InstanceMirror? instanceMirror = reflect(this).getField(#help);
    if (isNotNull(instanceMirror) && isTrue(instanceMirror!.reflectee)) {
      print(usage());
      exit(1);
    }
    var shell = GetIt.instance<IShell>();
    await run(shell, parentArguments);
  }

  Future<void> run(final IShell shell, final SmartArg parentArguments) async {}
}
