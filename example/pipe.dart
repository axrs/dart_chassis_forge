import 'dart:io' show Platform, stdout;

import 'package:chassis_forge/chassis_forge.dart';
import 'package:smart_arg_fork/smart_arg_fork.dart';

@SmartArg.reflectable
@Parser(
  description: 'A simple Pipe test',
)
class PipeCommand extends ChassisCommand with HelpArg {
  @override
  Future<void> run(
    IShell shell,
    SmartArg parentArguments,
  ) async {
    shell.requireCommand('more');
    IShellCommandBuilder pipe;
    if (Platform.isWindows) {
      pipe = shell
          .cmd('more README.md')
          .pipe('sort') //
          .pipe('findstr ${shellArgument("chassis")}') //
          .pipe('find /C ${shellArgument(" ")}');
    } else {
      pipe = shell
          .cmd('cat README.md')
          .pipe('sort') //
          .pipe('grep ${shellArgument("chassis")}') //
          .pipe('wc -l');
    }
    await stdout.flush();
    await pipe.run(stdout);
  }
}
