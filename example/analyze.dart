import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/chassis_forge_dart.dart';
import 'package:chassis_forge/smart_arg.dart';

const String analyzeDescription =
    'Runs static code analysis across the code base';

@SmartArg.reflectable
@Parser(
  description: analyzeDescription,
)
class AnalyzeCommand extends ChassisCommand with HelpOption {
  @override
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await shell.verbose().dartAnalyze();
  }
}
