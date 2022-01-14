import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

@SmartArg.reflectable
@Parser(
  description: 'Runs static code analysis across the code base',
)
class AnalyzeCommand extends ChassisCommand with HelpOption {
  @override
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(
    IShell shell,
    SmartArg parentArguments,
  ) async {
    await shell.verbose().run('dart analyze');
  }
}
