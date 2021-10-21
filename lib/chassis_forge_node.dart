/// CLI Helpers for working with Node.js, NPM, and NPX
library chassis_forge_node;

import 'package:chassis_forge/chassis_forge.dart';

import 'src/node.dart' as n;

export 'src/node.dart';

extension ChassisNode on IShell {
  /// Runs the specified npm [command]
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npm(String command) async {
    await n.npm(this, command);
    return this;
  }

  /// Installs the npm dependencies
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npmInstallDependencies({bool forCi = false}) async {
    await n.npm(this, forCi ? 'ci' : 'install');
    return this;
  }

  /// Runs `npm test`
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npmTest([String command = 'test']) async {
    await n.npm(this, command);
    return this;
  }

  /// Runs the specified npx [command]
  ///
  /// Throws [CommandNotFoundException] if `npx` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npx(String command) async {
    await n.npx(this, command);
    return this;
  }

  /// Runs the specified node [command]
  ///
  /// Throws [CommandNotFoundException] if `node` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> node(String command) async {
    await n.node(this, command);
    return this;
  }
}

extension ChassisNodeFutureShell on Future<IShell> {
  /// Runs the specified npm [command]
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npm(String command) async {
    return this.then((shell) async => await shell.npm(command));
  }

  /// Installs the npm dependencies
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npmInstallDependencies({bool forCi = false}) async {
    return this.then(
        (shell) async => await shell.npmInstallDependencies(forCi: forCi));
  }

  /// Runs the specified npx [command]
  ///
  /// Throws [CommandNotFoundException] if `npx` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npx(String command) async {
    return this.then((shell) async => await shell.npx(command));
  }

  /// Runs the specified node [command]
  ///
  /// Throws [CommandNotFoundException] if `node` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> node(String command) async {
    return this.then((shell) async => await shell.node(command));
  }

  /// Runs `npm test`
  ///
  /// Throws [CommandNotFoundException] if `npm` is not found
  ///
  /// `since 0.0.1`
  Future<IShell> npmTest([String command = 'test']) async {
    return this.then((shell) async => await shell.npm('$command'));
  }
}
