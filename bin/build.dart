import 'dart:io';

import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as dart;
import 'package:dart_rucksack/rucksack.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';

bool _isModifiedAfter(
  final File left,
  final FileSystemEntity right,
) {
  return left.lastModifiedSync().isBefore(right.statSync().modified);
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
  final String reflectableFilePath = file.absolute.path.replaceAll(
    RegExp(r'\.dart$'),
    '.reflectable.dart',
  );
  final File reflectable = File(reflectableFilePath);
  return isFalse(reflectable.existsSync()) ||
      _isModifiedAfter(reflectable, file);
}

/// Builds command reflectances
Future<void> main(List<String> args) async {
  final String folder = isNotEmpty(args) ? args.first : 'tool';
  _createChassisBuildYaml(folder);
  var rebuildIsRequired =
      Glob('$folder/**_command.dart').listSync().any(_reflectableNeedsUpdating);
  if (rebuildIsRequired) {
    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
    var shell = ProcessRunShell();
    await dart.build(shell, 'chassis');
  }
}
