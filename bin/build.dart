import 'dart:io';

import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as dart;
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';

bool _isDartFile(final FileSystemEntity file) {
  return file.path.endsWith('.dart');
}

bool _isReflectable(final FileSystemEntity file) {
  return file.path.endsWith('reflectable.dart');
}

String _rootName(final FileSystemEntity file) {
  return file.path.split(RegExp(r"\.")).first;
}

bool _isModifiedAfter(
  final FileSystemEntity left,
  final FileSystemEntity right,
) {
  return left.statSync().modified.isBefore(right.statSync().modified);
}

void _createChassisBuildYaml(final String folder) {
  final File config = File('build.chassis.yaml');
  if (!config.existsSync()) {
    config.writeAsString('''
targets:
  \$default:
    builders:
      reflectable:
        generate_for:
          - $folder/**_command.dart
''');
  }
}

bool _reflectableNeedsUpdating(final FileSystemEntity file) {
  print(file.uri);
  return false;
}

Future<void> main(List<String> args) async {
  final String folder = args.first;
  _createChassisBuildYaml(folder);
  final Glob glob = Glob('$folder/**_command.dart');
  var rebuildRequired = glob.listSync().any(_reflectableNeedsUpdating);
  if (rebuildRequired) {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
    var shell = ProcessRunShell();
    await dart.build(shell, 'chassis');
  }
}
