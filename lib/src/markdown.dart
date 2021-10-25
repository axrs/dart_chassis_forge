import 'dart:io';

import 'package:chassis_forge/src/node.dart' as node;
import 'package:chassis_forge/src/shell.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:rucksack/rucksack.dart';

final _log = Logger('cf:Markdown');

String _remarkConfig = '''
module.exports = {
  frail: true,
  plugins: {
    toc: {
      tight: true
    },
    'remark-gfm': true
  },
  settings: {
    bullet: '*',
    incrementListMarker: false,
    listItemIndent: '1'
  }
} 
''';

Future<void> _installRemark(IShell shell) async {
  _log.fine('Installing Remark');
  await shell.run('''
npm install --silent --no-save --no-audit --no-fund \\
  remark-cli \\
  remark-toc \\
  remark-gfm \\
  ccount \\
  mdast-util-find-and-replace
''');
}

/// Formats all Markdown files using Remark
///
/// `since 0.0.1`
Future<void> format(IShell shell) async {
  if (node.isMissingNpm(shell) || node.isMissingNpx(shell)) {
    _log.warning(
        'Skipping Formatting Markdown files. `npm` or `npx` not found.');
    return;
  }
  _log.info('Formatting Markdown Files...');
  final String workingDirectory = shell.workingDirectory();
  final String remarkPath =
      p.absolute(workingDirectory, ".chassis", "markdown");
  Directory(remarkPath).createSync(recursive: true);
  final remarkShell = shell.copyWith(workingDirectory: remarkPath);
  await _installRemark(remarkShell);
  var remarkRc = File('.remarkrc.js');
  var remarkConfigIsMissing = isFalse(remarkRc.existsSync());
  if (remarkConfigIsMissing) {
    _log.fine('Creating ${remarkRc.path} configuration');
    remarkRc.createSync();
    remarkRc.writeAsString(_remarkConfig);
  } else {
    _log.fine('Using existing ${remarkRc.path} configuration');
  }
  try {
    _log.info('Running Remark');
    final String projectPath = shell.workingDirectory() + p.separator;
    await remarkShell.run('npx remark $projectPath --output');
  } finally {
    if (remarkConfigIsMissing) {
      _log.fine('Cleaning Up ${remarkRc.path}');
      remarkRc.deleteSync();
    }
  }
}
