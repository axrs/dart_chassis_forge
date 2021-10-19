import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_node.dart' as chassis_node;
import 'package:smart_arg/smart_arg.dart';

const String versionsDescription = 'Prints various CLI Versions';

@SmartArg.reflectable
@Parser(
  description: versionsDescription,
)
class VersionsCommand extends ChassisCommand {
  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    print('Node: ${await chassis_node.nodeVersion(shell)}');
    print('NPM: ${await chassis_node.npmVersion(shell)}');
    print('NPX: ${await chassis_node.npxVersion(shell)}');
  }
}
