/// CLI Helpers for working with Markdown files
library chassis_forge_markdown;

import 'chassis_forge.dart';
import 'src/markdown.dart' as m;

export 'src/markdown.dart';

extension ChassisMarkdownShell on IShell {
  /// Formats all Markdown files using Remark
  ///
  /// `since 0.0.1`
  Future<IShell> markdownFormat() async {
    await m.format(this);
    return this;
  }
}

extension ChassisMarkdownFutureShell on Future<IShell> {
  /// Formats all Markdown files using Remark
  ///
  /// `since 0.0.1`
  Future<IShell> markdownFormat() async {
    return this.then((shell) async => await shell.markdownFormat());
  }
}
