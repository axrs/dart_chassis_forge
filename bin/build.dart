import 'dart:io';

import 'package:args/args.dart';
import 'package:chassis_forge/chassis_forge.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';

final Logger _log = Logger('cf:build');

bool _isNotBlank(String? v) {
  return v != null && v.trim().isNotEmpty;
}

bool _isModifiedAfter(
  FileSystemEntity left,
  FileSystemEntity right,
) {
  return left.statSync().modified.isBefore(right.statSync().modified);
}

void createChassisBuildYaml(String folder, [String? main]) {
  var config = File('build.chassis.yaml');
  if (!config.existsSync()) {
    _log.info('Creating $config for build');
    var mainCommandOrWildcard = main ?? '$folder/**_command.dart';
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

_requireFileExist(String file) {
  _log.info('Checking for existence of file $file');
  if (!File(file).existsSync()) {
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

Future<void> _compile(ArgResults args, IShell shell) async {
  String? executableTarget = args['executable-target'];
  String? mainScript = args['main'];
  if (_isNotBlank(executableTarget) &&
      _isNotBlank(mainScript) &&
      executableTarget != 'dart') {
    _requireFileExist(mainScript!);
    await shell.run('dart compile $executableTarget $mainScript');
  }
}

FileSystemEntity? _oldestReflectableFile(String chassisDir) {
  List<FileSystemEntity> reflectables =
      Glob('$chassisDir/**.reflectable.dart').listSync();
  reflectables.sort(
    (left, right) =>
        right.statSync().modified.compareTo(left.statSync().modified),
  );
  return reflectables.isEmpty ? null : reflectables.last;
}

bool _isReflectable(FileSystemEntity fileSystemEntity) {
  return fileSystemEntity.path.endsWith('reflectable.dart');
}

List<FileSystemEntity> _dartSourceFiles(String chassisDir) {
  List<FileSystemEntity> dartFiles = Glob('$chassisDir/**.dart').listSync();
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
      help: 'Main Command Entry File to Compile',
    )
    ..addOption(
      'executable-target',
      allowed: ['kernel', 'exe', 'dart'],
      defaultsTo: 'dart',
      help: 'Optional Compilation Target. Defaults to \'dart\'',
    )
    ..addOption(
      'directory',
      defaultsTo: 'tool',
      help: '[Ignored] '
          'Directory Command Source codes to check for re-compilation.',
    );
  return parser;
}

String extension(String kernelTarget) {
  if (kernelTarget == 'kernel') {
    return 'dill';
  } else if (kernelTarget == 'dart') {
    return 'dart';
  } else {
    return 'exe';
  }
}

Future<void> main(List<String> arguments) async {
  var parser = _buildParser();
  var args = parser.parse(arguments);
  if (args['help']) {
    print(parser.usage);
    exit(0);
  }
  _configureLogger(args['verbose']);
  var mainTool = args['main'];
  _requireFileExist(mainTool);
  var chassisDir = File(mainTool).parent.path.toString();
  if (chassisDir.startsWith('./')) {
    chassisDir = chassisDir.substring(1, chassisDir.length);
  }
  createChassisBuildYaml(chassisDir, mainTool);

  var executionMain = mainTool.replaceAll(
    RegExp(r'dart$'),
    extension(args['executable-target']),
  );
  var oldestReflectable = _oldestReflectableFile(chassisDir);
  var rebuildIsRequired =
      oldestReflectable == null || !File(executionMain).existsSync();
  if (!rebuildIsRequired) {
    rebuildIsRequired = _dartSourceFiles(chassisDir)
        .any((element) => _isModifiedAfter(oldestReflectable!, element));
  }
  if (!rebuildIsRequired && !args['force']) {
    return;
  }
  var shell = ProcessRunShell(verbose: args['verbose']);
  await shell.run(
    'dart run build_runner build '
    '--delete-conflicting-outputs '
    '--config chassis',
  );
  await _compile(args, shell);
}
