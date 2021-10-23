import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'main.reflectable.dart';

@SmartArg.reflectable
@Parser(
  description: 'Says Hello to a name',
)
class HelloCommand extends ChassisCommand with HelpOption {
  @override
  @HelpArgument()
  late bool help = false;

  @StringArgument(help: 'Say hello to')
  late String name = 'world';

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    print('Hello $name!');
  }
}

@SmartArg.reflectable
@Parser(
  description: 'A CLI Application',
)
class Forge extends ChassisForge with HelpOption, VerboseOption {
  @override
  @BooleanArgument(
    short: 'v',
    help: 'Enable Verbose Output',
  )
  late bool verbose = false;

  @override
  @HelpArgument()
  late bool help = false;

  @Command(help: 'Say Hello')
  late HelloCommand hello;
}

void main(List<String> arguments) {
  initializeReflectable();
  Forge().runWith(arguments);
}
