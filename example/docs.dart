import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/chassis_forge_dart.dart' as chassis_dart;
import 'package:smart_arg/smart_arg.dart';

const String docsDescription = 'Generates HTML documentation for the project';

@SmartArg.reflectable
@Parser(
  description: docsDescription,
)
class DocsCommand extends ChassisCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await chassis_dart.doc(shell);
  }
}
