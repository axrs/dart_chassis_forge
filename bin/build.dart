import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as dart;
import 'package:dart_rucksack/rucksack.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';

final _log = Logger('cf:build');

bool _isModifiedAfter(
  final File left,
  final FileSystemEntity right,
) {
  return left.lastModifiedSync().isBefore(right.statSync().modified);
}

void _createChassisBuildYaml(final String folder) {
  final File config = File('build.chassis.yaml');
  if (!config.existsSync()) {
    _log.info('Creating $config for build');
    config.writeAsStringSync('''
targets:
  \$default:
    builders:
      reflectable:
        generate_for:
          - $folder/**_command.dart
''');
  } else {
    _log.info('Using existing $config for build');
  }
}

final RegExp _dartFileRegex = RegExp(r'\.dart$');

bool _reflectableNeedsUpdating(final FileSystemEntity file) {
  final String reflectableFilePath = file.absolute.path.replaceAll(
    _dartFileRegex,
    '.reflectable.dart',
  );
  final File reflectable = File(reflectableFilePath);
  return isFalse(reflectable.existsSync()) ||
      _isModifiedAfter(reflectable, file);
}

_requireDirectoryExist(String directory) {
  _log.info('Checking for existence of directory $directory');
  if (isFalse(Directory(directory).existsSync())) {
    print('Directory $directory does not exist');
    exit(1);
  }
}

_requireFileExist(String file) {
  _log.info('Checking for existence of file $file');
  if (isFalse(File(file).existsSync())) {
    print('File $file does not exist');
    exit(1);
  }
}

_configureLogger(bool verbose) {
  Logger.root.level = verbose ? Level.FINE : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void _compile(ArgResults args, IShell shell) {
  String? executableTarget = args['executable-target'];
  String? mainScript = args['main'];
  if (isNotBlank(executableTarget) && isNotBlank(mainScript)) {
    _requireFileExist(mainScript!);
    dart.compile(shell, mainScript, executableTarget!);
  }
}

void main(List<String> arguments) {
  var parser = ArgParser()
    ..addFlag(
      'force',
      defaultsTo: false,
      negatable: false,
      help: 'Force a recompilation',
    )
    ..addFlag(
      'verbose',
      defaultsTo: false,
      negatable: false,
      help: 'Enable Verbose Output',
    )
    ..addFlag(
      'help',
      help: 'Show Help',
      negatable: false,
    )
    ..addOption(
      'main',
      help: 'Optional Main Command Entry File to Compile',
    )
    ..addOption(
      'executable-target',
      allowed: ['kernel', 'exe'],
      help: 'Optional Compilation Target',
    )
    ..addOption(
      'directory',
      defaultsTo: 'tool',
      help: 'Directory Command Source codes to check for re-compilation',
    );

  var args = parser.parse(arguments);
  if (args['help']) {
    print(parser.usage);
    exit(0);
  }
  _configureLogger(args['verbose']);
  final String chassisDir = args['directory'];
  _requireDirectoryExist(chassisDir);
  _createChassisBuildYaml(chassisDir);
  var rebuildIsRequired = Glob('$chassisDir/**_command.dart')
      .listSync()
      .any(_reflectableNeedsUpdating);
  if (isFalse(rebuildIsRequired) && isFalse(args['force'])) {
    return;
  }
  var shell = ProcessRunShell(verbose: args['verbose']);
  dart.build(shell, 'chassis').then((value) => _compile(args, shell));
}
