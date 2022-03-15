import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

@SmartArg.reflectable
@Parser(
  description: 'Installs Dependencies for the project',
)
class DepsCommand extends ChassisCommand with HelpArg {
  @BooleanArgument(help: 'Upgrade with compatible versions?')
  late bool upgrade = false;

  @override
  Future<void> run(IShell shell, SmartArg parentArguments) async {
    await shell.run('dart pub ${upgrade ? 'upgrade' : 'get'}');
  }
}
