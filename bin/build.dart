import 'dart:io';

import 'package:args/args.dart';
import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/chassis_forge_dart.dart' as dart;
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';
import 'package:rucksack/rucksack.dart';

final Logger _log = Logger('cf:build');

bool _isModifiedAfter(
  final FileSystemEntity left,
  final FileSystemEntity right,
) {
  return left.statSync().modified.isBefore(right.statSync().modified);
}

void createChassisBuildYaml(final String folder, [final String? main]) {
  final File config = File('build.chassis.yaml');
  if (!config.existsSync()) {
    _log.info('Creating $config for build');
    final String mainCommandOrWildcard = main ?? '$folder/**_command.dart';
    config.writeAsStringSync(
      '''
targets:
  \$default:
    sources:
      - $folder/**
      - \$package\$
      - lib/\$lib\$
    builders:
      reflectable:
        generate_for:
          - $mainCommandOrWildcard
''',
    );
  } else {
    _log.info('Using existing $config for build');
  }
}

void createAnalysisOptions(final String folder) {
  final File config = File('analysis_options.yaml');
  if (!config.existsSync()) {
    _log.info('Creating $config for analysis');
    config.writeAsStringSync(
      '''
include: package:lints/recommended.yaml

linter:
  rules:
    - unawaited_futures
    - prefer_single_quotes
    - require_trailing_commas

analyzer:
  exclude:
    - example/*.reflectable.dart
    - $folder/*.reflectable.dart
    - test/*.reflectable.dart
''',
    );
  } else {
    _log.info('Using existing $config for analysis');
  }
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
  final String? executableTarget = args['executable-target'];
  final String? mainScript = args['main'];
  if (isNotBlank(executableTarget) &&
      isNotBlank(mainScript) &&
      executableTarget != 'dart') {
    _requireFileExist(mainScript!);
    dart.compile(shell, mainScript, executableTarget!);
  }
}

FileSystemEntity? _oldestReflectableFile(String chassisDir) {
  final List<FileSystemEntity> reflectables =
      Glob('$chassisDir/**.reflectable.dart').listSync();
  reflectables.sort(
    (left, right) =>
        right.statSync().modified.compareTo(left.statSync().modified),
  );
  return reflectables.isEmpty ? null : reflectables.last;
}

bool _isReflectable(final FileSystemEntity fileSystemEntity) {
  return fileSystemEntity.path.endsWith('reflectable.dart');
}

List<FileSystemEntity> _dartSourceFiles(String chassisDir) {
  final List<FileSystemEntity> dartFiles =
      Glob('$chassisDir/**.dart').listSync();
  dartFiles.removeWhere(_isReflectable);
  return dartFiles;
}

ArgParser _buildParser() {
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
      allowed: ['kernel', 'exe', 'dart'],
      help: 'Optional Compilation Target',
    )
    ..addOption(
      'directory',
      defaultsTo: 'tool',
      help: 'Directory Command Source codes to check for re-compilation',
    );
  return parser;
}

void main(List<String> arguments) {
  final ArgParser parser = _buildParser();
  final ArgResults args = parser.parse(arguments);
  if (args['help']) {
    print(parser.usage);
    exit(0);
  }
  _configureLogger(args['verbose']);
  final String chassisDir = args['directory'];
  _requireDirectoryExist(chassisDir);
  createChassisBuildYaml(chassisDir, args['main']);
  final FileSystemEntity? oldestReflectable =
      _oldestReflectableFile(chassisDir);
  bool rebuildIsRequired = isNull(oldestReflectable);
  if (isFalse(rebuildIsRequired)) {
    rebuildIsRequired = _dartSourceFiles(chassisDir)
        .any((element) => _isModifiedAfter(oldestReflectable!, element));
  }
  if (isFalse(rebuildIsRequired) && isFalse(args['force'])) {
    return;
  }
  final IShell shell = ProcessRunShell(verbose: args['verbose']);
  dart.build(shell, 'chassis').then((value) => _compile(args, shell));
}
