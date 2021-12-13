/// CLI helpers for working with Dart based projects
library chassis_forge_dart;

import 'package:chassis_forge/chassis_forge.dart';

import 'src/dart.dart' as d;

export 'src/dart.dart';

extension ChassisDart on IShell {
  /// Runs the Dart formatter
  ///
  /// `since 0.0.1`
  Future<IShell> dartFormat() async {
    await d.format(this);
    return this;
  }

  /// Analyzes the Dart source files for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartAnalyze() async {
    await d.analyze(this);
    return this;
  }

  /// Runs the Dart Documentation Generator
  ///
  /// `since 0.0.1`
  Future<IShell> dartDoc({
    String output = 'doc',
    String format = 'html',
  }) async {
    await d.doc(
      this,
      output: output,
      format: format,
    );
    return this;
  }

  /// Unit Tests the Dart source files for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartTest() async {
    await d.test(verbose());
    return this;
  }

  /// Installs dependencies for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartInstallDependencies({bool upgrade = false}) async {
    await d.installDependencies(this, upgrade: upgrade);
    return this;
  }

  /// Builds the Dart source files for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartBuild([String? config]) async {
    await d.build(this, config);
    return this;
  }

  /// Compiles the specified [dartFile] into the target [executableType]
  ///
  /// `since 0.0.1`
  Future<IShell> dartCompile(
    String dartFile, [
    String executableType = 'kernel',
  ]) async {
    await d.compile(this, dartFile, executableType);
    return this;
  }
}

extension ChassisDartFutureShell on Future<IShell> {
  /// Runs the Dart Documentation Generator
  ///
  /// `since 0.0.1`
  Future<IShell> dartDoc({
    String output = 'docs',
    String format = 'html',
  }) async {
    return then(
      (shell) async => await shell.dartDoc(
        output: output,
        format: format,
      ),
    );
  }

  /// Runs the Dart formatter
  ///
  /// `since 0.0.1`
  Future<IShell> dartAnalyze() async {
    return then((shell) async => await shell.dartAnalyze());
  }

  /// Runs the Dart formatter
  ///
  /// `since 0.0.1`
  Future<IShell> dartFormat() async {
    return then((shell) async => await shell.dartFormat());
  }

  /// Unit Tests the Dart source files for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartTest() async {
    return then((shell) async => await shell.dartTest());
  }

  /// Installs dependencies for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartInstallDependencies({bool upgrade = false}) async {
    return then((shell) async => await shell.dartInstallDependencies());
  }

  /// Builds the Dart source files for the current dart project
  ///
  /// `since 0.0.1`
  Future<IShell> dartBuild([String? config]) async {
    return then((shell) async => await shell.dartBuild(config));
  }

  /// Compiles the specified [dartFile] into the target [executableType]
  ///
  /// `since 0.0.1`
  ///
  Future<IShell> dartCompile(
    String dartFile, [
    String executableType = 'kernel',
  ]) async {
    return then(
      (shell) async => //
          await shell.dartCompile(dartFile, executableType),
    );
  }
}
