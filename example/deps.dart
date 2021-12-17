import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/chassis_forge_dart.dart';
import 'package:chassis_forge/smart_arg.dart';

@SmartArg.reflectable
@Parser(
  description: 'Generates HTML documentation for the project',
)
class DepsCommand extends ChassisCommand with HelpOption {
  @override
  @HelpArgument()
  late bool help = false;

  @BooleanArgument(help: 'Upgrade with compatible versions?')
  late bool upgrade = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await shell.dartInstallDependencies(upgrade: upgrade);
  }
}
