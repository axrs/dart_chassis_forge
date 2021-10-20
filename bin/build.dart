import 'dart:io';

import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as dart;
import 'package:dart_rucksack/rucksack.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';
import 'package:smart_arg/smart_arg.dart';

import 'build.reflectable.dart';

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

@SmartArg.reflectable
@Parser(description: 'Dart Chassis Forge Builder')
class Args extends SmartArg {
  @StringArgument(
    help: 'Command Source File Directory',
    isRequired: true,
  )
  String directory = 'tool';

  @StringArgument(
    help: 'Compile the entry command into the specified executable target',
    mustBeOneOf: ['kernel', 'native'],
  )
  String? executableTarget; // Default to Hello

  @StringArgument(
    help: 'Compile the entry command into the specified executable target',
  )
  String? main = null;

  @HelpArgument()
  bool help = false;

  @BooleanArgument(
    short: 'v',
    help: 'Enable Command Verbose Mode',
  )
  late bool verbose = false;

  @BooleanArgument(help: 'Force executable compilation')
  late bool force = false;
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

void _compile(Args args, IShell shell) {
  String? executableTarget = args.executableTarget;
  String? mainScript = args.main;
  if (isNotBlank(executableTarget) && isNotBlank(mainScript)) {
    _requireFileExist(mainScript!);
    dart.compile(shell, mainScript, executableTarget!);
  }
}

void main(List<String> arguments) {
  initializeReflectable();
  var args = Args()..parse(arguments);
  if (args.help) {
    print(args.usage());
    exit(0);
  }
  _configureLogger(args.verbose);
  final String chassisDir = args.directory;
  _requireDirectoryExist(chassisDir);
  _createChassisBuildYaml(chassisDir);
  var rebuildIsRequired = Glob('$chassisDir/**_command.dart')
      .listSync()
      .any(_reflectableNeedsUpdating);
  if (isFalse(rebuildIsRequired) && isFalse(args.force)) {
    return;
  }
  var shell = ProcessRunShell(verbose: args.verbose);
  dart.build(shell, 'chassis').then((value) => _compile(args, shell));
}
