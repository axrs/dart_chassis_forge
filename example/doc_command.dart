import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as chassis_dart;
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'analyze_command.reflectable.dart';

const String docDescription = 'Generates HTML documentation for the project';

@SmartArg.reflectable
@Parser(
  description: docDescription,
)
class DocCommand extends ChassisCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await chassis_dart.doc(shell);
  }
}
