import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'format_command.reflectable.dart';

const String formatDescription =
    'Runs the various source code formatting tools';

@SmartArg.reflectable
@Parser(
  description: formatDescription,
)
class FormatCommand extends ChassisCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await format(shell);
  }
}
