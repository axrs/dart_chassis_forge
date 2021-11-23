import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg/smart_arg.dart';

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

  @Command(help: analyzeDescription)
  late AnalyzeCommand analyze;

  @Command(help: docsDescription)
  late DocsCommand docs;

  @Command(help: depsDescription)
  late DepsCommand deps;

  @Command(help: formatDescription)
  late FormatCommand format;
}

void main(List<String> arguments) {
  initializeReflectable();
  ExampleForge().runWith(arguments);
}
