import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'analyze.dart';
import 'deps.dart';
import 'docs.dart';
import 'format.dart';
// ignore: unused_import
import 'main.reflectable.dart';

@SmartArg.reflectable
@Parser(
  description: 'Dart Chassis Forge Project Helper Tools',
)
class ExampleForge extends ChassisForge with HelpOption, VerboseOption {
  @override
  @BooleanArgument(
    short: 'v',
    help: 'Enable Command Verbose Mode',
  )
  late bool verbose = false;

  @override
  @HelpArgument()
  late bool help = false;

  @Command()
  late AnalyzeCommand analyze;

  @Command()
  late DocsCommand docs;

  @Command()
  late DepsCommand deps;

  @Command()
  late FormatCommand format;

  @Command()
  late ExampleForge nested;
}

void main(List<String> arguments) {
  initializeReflectable();
  ExampleForge().runWith(arguments);
}
