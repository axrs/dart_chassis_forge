import 'dart:io' show stdout;

import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

@SmartArg.reflectable
@Parser(
  description: 'A simple ag->jq Pipe test',
)
class AgJqPipeCommand extends ChassisCommand with HelpArg {
  @override
  Future<void> run(
    IShell shell,
    SmartArg parentArguments,
  ) async {
    await shell
        .cmd(
          'ag --nocolor --nogroup --nonumbers --context=0 --nofilename "three" *.jsonl',
        )
        .pipe('jq --color-output --unbuffered --raw-output .')
        .run(stdout);
  }
}
