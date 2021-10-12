library chassis_forge;

import 'src/dart.dart' as dart;
import 'src/markdown.dart' as markdown;
import 'src/shell.dart';

export 'src/shell.dart';

Future<void> format(IShell shell) async {
  await dart.format(shell);
  await markdown.format(shell);
}

Future<void> analyze(IShell shell) async {
  await dart.analyze(shell);
}

Future<void> test(IShell shell) async {
  await dart.test(shell);
}
