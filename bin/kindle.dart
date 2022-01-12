import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/shell.dart' as pr;
import 'package:rucksack/rucksack.dart';

import 'build.dart' show createChassisBuildYaml;

final Logger _log = Logger('cf:kindle');

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

Future<String> promptUntilNotBlank(
  String prompt,
  String whenBlank, [
  String? defaultValue,
]) async {
  var promptExtra = isNotBlank(defaultValue) ? ' <$defaultValue>' : '';
  String? result = await pr.prompt('$prompt$promptExtra');
  if (isBlank(result)) {
    if (isBlank(defaultValue)) {
      printError('$whenBlank\n');
      return promptUntilNotBlank(prompt, whenBlank);
    } else {
      result = defaultValue;
    }
  }
  return result!;
}

Future<String> promptUntilValueIn(
  String prompt,
  String whenInvalid,
  List<String> acceptableValues, [
  String? defaultValue,
]) async {
  var promptExtra = isNotBlank(defaultValue) ? ' <$defaultValue>' : '';
  String? result = await pr.prompt('$prompt$promptExtra');
  if (isBlank(result)) {
    if (isBlank(defaultValue)) {
      printError('$whenInvalid\n');
      return promptUntilValueIn(prompt, whenInvalid, acceptableValues);
    } else {
      result = defaultValue;
    }
  }
  if (!acceptableValues.contains(result)) {
    return promptUntilValueIn(prompt, whenInvalid, acceptableValues);
  }
  return result!;
}

String mainForgeTemplate = '''
import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/smart_arg.dart';

// ignore: unused_import
import 'main.reflectable.dart';

@SmartArg.reflectable
@Parser(
  description: 'Says Hello to a name',
)
class HelloCommand extends ChassisCommand with HelpOption {
  @override
  @HelpArgument()
  late bool help = false;

  @StringArgument(help: 'Say hello to')
  late String name = 'world';

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    print('Hello \$name!');
  }
}

@SmartArg.reflectable
@Parser(
  description: 'A CLI Application',
)
class Forge extends ChassisForge with HelpOption, VerboseOption {
  @override
  @BooleanArgument(
    short: 'v',
    help: 'Enable Verbose Output',
  )
  late bool verbose = false;

  @override
  @HelpArgument()
  late bool help = false;

  @Command(help: 'Say Hello')
  late HelloCommand hello;
}

void main(List<String> arguments) {
  initializeReflectable();
  Forge().runWith(arguments);
}
''';

void createMain(String mainEntryCommandPath) {
  var mainFile = File(mainEntryCommandPath);
  if (mainFile.existsSync()) {
    printWarning(
      'Skipping Main Entry Command creation at $mainFile as file already exists.',
    );
  } else {
    print('Creating Main Entry Command: $mainFile');
    mainFile.createSync(recursive: true);
    mainFile.writeAsStringSync(mainForgeTemplate);
  }
}

void createBuildConfig(String directory, String mainEntryCommandPath) {
  var buildConfigFile = File('build.chassis.yaml');
  if (buildConfigFile.existsSync()) {
    printWarning(
      'Skipping Build Config generation as $buildConfigFile already exists.',
    );
  } else {
    print('Creating Build Config: $buildConfigFile');
    createChassisBuildYaml(directory, mainEntryCommandPath);
  }
}

void _writeAnalysisOptions(String folder) {
  var config = File('analysis_options.yaml');
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

void createAnalysisOptions(String directory) {
  var analysisConfigFile = File('analysis_options.yaml');
  if (analysisConfigFile.existsSync()) {
    printWarning(
      'Skipping Analysis Config generation as $analysisConfigFile already exists.',
    );
  } else {
    print('Creating Analysis Config: $analysisConfigFile');
    _writeAnalysisOptions(directory);
  }
}

void createScript(String extension, String scriptContent) {
  var currentDir = p.basename(Directory.current.path);
  var scriptFile = File('$currentDir.$extension');
  if (scriptFile.existsSync()) {
    printWarning(
      'Skipping Script helper generation as $scriptFile already exists.',
    );
  } else {
    print('Creating Helper Script: $scriptFile');
    scriptFile.createSync(recursive: true);
    scriptFile.writeAsStringSync(scriptContent);
  }
}

void createPs1Helper(
  String directory,
  String executableTarget,
  String main,
  String compiledMain,
) {
  var ps1 = '''
#!/usr/bin/env pwsh
If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart pub get | Out-Null
}
& dart run chassis_forge:build --directory $directory --main $directory/$main --executable-target $executableTarget --verbose | Out-Null
& dart run $directory/$compiledMain @args
''';
  createScript('ps1', ps1);
}

void createShHelper(
  String directory,
  String executableTarget,
  String main,
  String compiledMain,
) {
  var sh = '''
#!/usr/bin/env bash
set -euo pipefail
if [ ! -d '.dart_tool' ] || [ ! -f 'pubspec.lock' ];then
  dart pub get >/dev/null
fi
dart run chassis_forge:build --directory $directory --main $directory/$main --executable-target $executableTarget --verbose >/dev/null
# shellcheck disable=SC2068
dart run $directory/$compiledMain "\$@"
''';
  createScript('sh', sh);
}

Future<void> main(List<String> arguments) async {
  print('Laying down kindling for Chassis Forge');
  var directory = await promptUntilNotBlank(
    'Where should the Chassis Forge tools be placed',
    'A directory is required for Chassis Forge Tools',
    'tool',
  );
  var mainTool = await promptUntilNotBlank(
    'What will the name of the entry command',
    'An entry command name is required',
    'main.dart',
  );
  var executionTarget = await promptUntilValueIn(
    'How would you like the Forge to be welded?',
    'A valid execution target is required',
    ['kernel', 'dart'],
    'kernel',
  );
  if (isFalse(mainTool.endsWith('.dart'))) {
    mainTool = '$mainTool.dart';
  }
  print('\nDo you wish to proceed laying kindling?');
  print('\twith a base directory of: $directory');
  print('\tand a main tool path of: $directory/$mainTool');
  print('\tand an execution target of: $executionTarget');
  var proceed = await pr.promptConfirm('');
  if (isTrue(proceed)) {
    var mainEntryCommandPath = p.join(directory, mainTool);
    print('\nLaying Kindling...');
    createMain(mainEntryCommandPath);
    createBuildConfig(directory, '$directory/$mainTool');
    createAnalysisOptions(directory);
    var extension = 'dart';
    switch (executionTarget) {
      //TODO Support Exe
      case 'kernel':
        extension = 'dill';
        break;
    }
    var executionMain = mainTool.replaceAll(RegExp(r'dart$'), extension);
    createPs1Helper(directory, executionTarget, mainTool, executionMain);
    createShHelper(directory, executionTarget, mainTool, executionMain);
    exit(0);
  } else {
    exit(1);
  }
}
