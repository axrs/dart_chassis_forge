import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'analyze_command.reflectable.dart';

const String analyzeDescription =
    'Runs static code analysis across the code base';

@SmartArg.reflectable
@Parser(
  description: analyzeDescription,
)
class AnalyzeCommand extends ChassisCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await analyze(shell);
  }
}
