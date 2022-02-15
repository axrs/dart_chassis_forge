import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

import 'analyze.dart';
import 'deps.dart';
import 'docs.dart';
import 'format.dart'; // ignore: unused_import
import 'main.reflectable.dart';

@SmartArg.reflectable
@Parser(
  description: 'Dart Chassis Forge Project Helper Tools',
)
class ExampleForge extends ChassisForge with HelpArg, VerboseArg {
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

Future<void> main(List<String> arguments) async {
  initializeReflectable();
  var forge = ExampleForge();
  await forge.runWith(arguments);
}
