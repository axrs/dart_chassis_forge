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
    'remark-gfm': true,
    'remark-preset-lint-consistent': true,
    'remark-preset-lint-recommended': true
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
  await shell.run(
    '''
npm install --silent --no-audit --no-fund \\
  remark-cli@10.0.1 \\
  remark-gfm@3.0.1 \\
  remark-toc@8.0.1 \\
  remark-preset-lint-consistent@5.1.0 \\
  remark-preset-lint-recommended@6.1.1
''',
  );
}

/// Formats all Markdown files using Remark
///
/// `since 0.0.1`
Future<void> format(IShell shell) async {
  if (node.isMissingNpm(shell) || node.isMissingNpx(shell)) {
    _log.warning(
      'Skipping Formatting Markdown files. `npm` or `npx` not found.',
    );
    return;
  }
  _log.info('Formatting Markdown Files...');
  final String workingDirectory = shell.workingDirectory();
  final String remarkPath =
      p.absolute(workingDirectory, '.chassis', 'markdown');
  Directory(remarkPath).createSync(recursive: true);
  final remarkShell = shell.copyWith(workingDirectory: remarkPath);
  final String remarkShellWorkingDir = remarkShell.workingDirectory();
  await _installRemark(remarkShell);
  var remarkRc = File(p.join(remarkShellWorkingDir, '.remarkrc.js'));
  var remarkConfigIsMissing = isFalse(remarkRc.existsSync());
  if (remarkConfigIsMissing) {
    _log.fine('Creating ${remarkRc.path} configuration');
    remarkRc.createSync();
    await remarkRc.writeAsString(_remarkConfig);
  } else {
    _log.fine('Using existing ${remarkRc.path} configuration');
  }
  try {
    _log.info('Running Remark');
    final String projectPath = shell.workingDirectory() + p.separator;
    await remarkShell.run(
      'npx --prefix $remarkShellWorkingDir remark $projectPath --output',
    );
  } finally {
    if (remarkConfigIsMissing) {
      _log.fine('Cleaning Up ${remarkRc.path}');
      remarkRc.deleteSync();
    }
  }
}
