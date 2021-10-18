import 'dart:io';

import 'package:dart_chassis_forge/src/node.dart' as node;
import 'package:dart_chassis_forge/src/shell.dart';
import 'package:dart_rucksack/rucksack.dart';
import 'package:logging/logging.dart';

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
  await _installRemark(shell);
  var remarkRc = File('.remarkrc.js');
  var remarcConfigIsMissing = isFalse(remarkRc.existsSync());
  if (remarcConfigIsMissing) {
    _log.fine('Creating ${remarkRc.path} configuration');
    remarkRc.createSync();
    remarkRc.writeAsString(_remarkConfig);
  } else {
    _log.fine('Using existing ${remarkRc.path} configuration');
  }
  try {
    _log.info('Running Remark');
    await shell.run('npx remark . --output');
  } finally {
    if (remarcConfigIsMissing) {
      _log.fine('Cleaning Up ${remarkRc.path}');
      remarkRc.deleteSync();
    }
  }
}
