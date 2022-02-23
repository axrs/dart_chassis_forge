import 'dart:io' show Platform;

import 'package:chassis_forge/chassis_forge.dart';
import 'package:test/test.dart';

void main() {
  group('ProcessRunShell', () {
    late IShell shell;

    setUp(() {
      shell = ProcessRunShell();
    });

    group('pipe commands', () {
      test('single command', () async {
        var cmd = Platform.isWindows ? 'more' : 'cat';
        var res = await shell.cmd('$cmd ${shellArgument('README.md')}').run();
        expect(res.stdout, startsWith('# Chassis Forge'));
      });

      test('multi-piping', () async {
        IShellCommandBuilder pipe;
        if (Platform.isWindows) {
          pipe = shell
              .cmd('more README.md')
              .pipe('sort') //
              .pipe('findstr ${shellArgument("chassis")}') //
              .pipe('find /C ${shellArgument(" ")}');
        } else {
          pipe = shell
              .cmd('cat README.md')
              .pipe('sort') //
              .pipe('grep ${shellArgument("chassis")}') //
              .pipe('wc -l');
        }
        var res = await pipe.run();
        expect(res.stdout, equals('12'));
      });

      test('exceptions not thrown if not requested (start)', () async {
        var res = shell
            .withThrowOnError(false)
            .cmd('dart run-a-command-that-doesnt-exist')
            .pipe('sort')
            .pipe('sort');

        var actual = await res.run() as PipedProcessResult;

        expect(actual.exitCode, equals(0));
        expect(actual.stdout, equals(''));
        expect(actual.stderr, equals(''));
        expect(actual.pipeResults.length, equals(3));
        expect(actual.pipeResults.first.exitCode, greaterThan(0));
        expect(
          actual.pipeResults.first.stderr,
          startsWith('Could not find a command named'),
        );
      });

      test('exceptions not thrown if not requested (mid)', () async {
        var cmd = Platform.isWindows ? 'more' : 'cat';
        var res = shell
            .withThrowOnError(false)
            .cmd('$cmd README.md')
            .pipe('dart this-doesnt-exist')
            .pipe('sort');

        var actual = await res.run() as PipedProcessResult;

        expect(actual.exitCode, equals(0));
        expect(actual.stdout, equals(''));
        expect(actual.stderr, equals(''));
        expect(actual.pipeResults[1].exitCode, greaterThan(0));
        expect(
          actual.pipeResults[1].stderr,
          startsWith('Could not find a command named'),
        );
      });

      test('exceptions not thrown if not requested (tail)', () async {
        var cmd = Platform.isWindows ? 'more' : 'cat';
        var res = shell
            .withThrowOnError(false)
            .cmd('$cmd README.md')
            .pipe('sort')
            .pipe('dart this-doesnt-exist');

        var actual = await res.run() as PipedProcessResult;

        expect(actual.exitCode, greaterThan(0));
        expect(actual.stdout, equals(''));
        expect(
          actual.stderr,
          startsWith('Could not find a command named'),
        );
      });

      test('exceptions thrown if requested (start)', () async {
        var res = shell
            .withThrowOnError(true)
            .cmd('dart this-doesnt-exist')
            .pipe('sort')
            .pipe('sort');

        expect(
          () async => await res.run(),
          throwsA(TypeMatcher<PipedCommandResultException>()),
        );

        try {
          await res.run();
          expect(true, isFalse);
        } on PipedCommandResultException catch (ex) {
          expect(ex.message, equals(''));
          expect(ex.command, equals('dart this-doesnt-exist | sort | sort'));
          expect(ex.results.exitCode, greaterThan(0));
          expect(ex.results.pipeResults[0].exitCode, greaterThan(0));
          expect(ex.results.pipeResults[1].exitCode, equals(0));
          expect(ex.results.pipeResults[2].exitCode, equals(0));
        }
      });

      test('exceptions thrown if requested (mid)', () async {
        var cmd = Platform.isWindows ? 'more' : 'cat';
        var res = shell
            .withThrowOnError(true)
            .cmd('$cmd README.md')
            .pipe('dart this-doesnt-exist')
            .pipe('sort');

        expect(
          () async => await res.run(),
          throwsA(TypeMatcher<PipedCommandResultException>()),
        );
      });

      test('exceptions thrown if requested (tail)', () async {
        var cmd = Platform.isWindows ? 'more' : 'cat';
        var res = shell
            .withThrowOnError(true)
            .cmd('$cmd README.md')
            .pipe('dart this-doesnt-exist');

        expect(
          () async => await res.run(),
          throwsA(TypeMatcher<PipedCommandResultException>()),
        );
      });
    });

    group('which', () {
      test(
          'throws MultipleScriptCommandException if multiple commands are found',
          () {
        var multipleCommands = '''
        dart --version
        pub --version
        ''';

        expect(
          () => shell.which(multipleCommands),
          throwsA(TypeMatcher<MultipleScriptCommandException>()),
        );
      });

      test('resolves the path of the executable if found', () {
        expect(shell.which('dart'), isNotEmpty);
        if (Platform.isWindows) {
          expect(shell.which('dart'), endsWith('dart.exe'));
        } else {
          expect(shell.which('dart'), endsWith('dart'));
        }
      });

      test('resolves null if the command is not found', () {
        expect(shell.which('dart-exe-is-not-found'), isNull);
      });
    });

    group('hasCommand', () {
      test('true if the current system has the specified command', () {
        expect(shell.hasCommand('dart'), isTrue);
        expect(shell.hasCommand('dart-not-found'), isFalse);
      });

      test('throws exception if multiple commands are passed', () {
        expect(
          () => shell.which(
            '''
          dart
          flutter
          ''',
          ),
          throwsA(TypeMatcher<MultipleScriptCommandException>()),
        );
      });
    });

    group('supportsColorOutput', () {
      test('true if the current shell supports color output', () {
        expect(shell.supportsColorOutput(), isFalse);
        expect(shell.copyWith(color: false).supportsColorOutput(), isFalse);
        expect(shell.copyWith(color: true).supportsColorOutput(), isTrue);
      });
    });

    group('requireCommand', () {
      test('throws exception if multiple commands are passed', () {
        expect(
          () => shell.requireCommand(
            '''
          dart
          flutter
          ''',
          ),
          throwsA(TypeMatcher<MultipleScriptCommandException>()),
        );
      });

      test('throws exception if the command is not found', () {
        expect(
          () => shell.requireCommand('dart-not-found'),
          throwsA(TypeMatcher<CommandNotFoundException>()),
        );
      });

      test('does nothing if command is found', () {
        expect(() => shell.requireCommand('dart'), returnsNormally);
      });
    });

    group('copyWith', () {
      test('verbose', () {
        expect(shell.copyWith(verbose: false).isVerbose(), isFalse);
        expect(shell.copyWith(verbose: true).isVerbose(), isTrue);
        expect(shell.verbose().isVerbose(), isTrue);
        expect(shell.verbose(false).isVerbose(), isFalse);
        expect(shell.verbose(false).verbose().isVerbose(), isTrue);
      });

      test('color', () {
        expect(shell.copyWith(color: false).supportsColorOutput(), isFalse);
        expect(shell.copyWith(color: true).supportsColorOutput(), isTrue);
        expect(shell.colored().supportsColorOutput(), isTrue);
        expect(shell.colored(false).supportsColorOutput(), isFalse);
        expect(shell.colored(false).colored().supportsColorOutput(), isTrue);
      });

      test('workingDirectory', () {
        var wd = '/some/working/directory';
        expect(
          shell.copyWith(workingDirectory: wd).workingDirectory(),
          equals(wd),
        );
        expect(shell.withWorkingDirectory(wd).workingDirectory(), equals(wd));
        expect(shell.workingDirectory(), isNot(equals(wd)));
      });

      test('environment', () {
        var expected = {'key': 'value'};
        expect(
          shell.copyWith(environment: expected).environment(),
          equals(expected),
        );

        expect(
          shell.withEnvironment(expected).environment(),
          equals(expected),
        );
      });

      test('throwOnError', () {
        expect(shell.copyWith(throwOnError: false).throwsOnError(), isFalse);
        expect(shell.copyWith(throwOnError: true).throwsOnError(), isTrue);
      });
    });

    group('run', () {
      test('throws an exception if multiple commands', () async {
        expect(
          () async => await shell.run(
            '''
        dart --version
        flutter --version
        ''',
          ),
          throwsA(TypeMatcher<MultipleScriptCommandException>()),
        );
      });

      test('does not throw an exception unless requested', () async {
        expect(
          () async =>
              await shell.withThrowOnError().run('dart this-doesnt-exist'),
          throwsA(TypeMatcher<ChassisShellException>()),
        );

        var actual = await shell
            .withThrowOnError(false) //
            .run('dart this-doesnt-exist');
        expect(actual.exitCode, greaterThan(0));
      });

      test('runs with the supplied environment', () async {
        var cmd = Platform.isWindows
            ? 'echo %FINDTHISVALUE%'
            : 'bash -c "echo \$FINDTHISVALUE"';
        var env = {'FINDTHISVALUE': '12345'};
        var withEnvironment = shell.withEnvironment(env);

        var actualWithEnvironment = await withEnvironment.run(cmd);

        var actualWithParam = await withEnvironment
            .run(cmd, environment: {'FINDTHISVALUE': '6789'});

        expect(actualWithEnvironment.stdout, equals('12345'));
        expect(actualWithParam.stdout, equals('6789'));
      });

      test('executes the specified command', () async {
        var actual = await shell.run('dart --help');

        expect(actual, isNotNull);
        expect(actual.exitCode, isZero);
        expect(actual.stderr, isEmpty);
        expect(
          actual.stdout,
          startsWith('A command-line utility for Dart development.\n'),
        );
        expect(actual.stdout, isNot(endsWith('\n')));
      });

      test('can supply a list of arguments', () async {
        var actual = await shell.run('dart', args: ['--help']);

        expect(actual, isNotNull);
        expect(actual.exitCode, isZero);
        expect(actual.stderr, isEmpty);
        expect(
          actual.stdout,
          startsWith('A command-line utility for Dart development.\n'),
        );
        expect(actual.stdout, isNot(endsWith('\n')));
      });

      test('can supply a list of arguments [multi]', () async {
        var actual = await shell.run(
          'dart',
          args: [
            'run',
            'build_runner',
            'build',
            '--config',
            'chassis',
            '--delete-conflicting-outputs'
          ],
        );

        expect(actual, isNotNull);
        expect(actual.exitCode, isZero);
        expect(actual.stderr, isEmpty);
        expect(
          actual.stdout,
          startsWith('[INFO] Generating build script...'),
        );
        expect(actual.stdout, isNot(endsWith('\n')));
      });

      test('can supply a list of arguments with basic quoting', () async {
        var actual = await shell.run('echo', args: ['hello world']);

        expect(actual, isNotNull);
        expect(actual.exitCode, isZero);
        expect(actual.stderr, isEmpty);
        expect(
          actual.stdout,
          contains('hello world'),
        );
        expect(actual.stdout, isNot(endsWith('\n')));
      });
    });
  });
}
