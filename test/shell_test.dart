import 'dart:io' show Platform;

import 'package:chassis_forge/chassis_forge.dart';
import 'package:test/test.dart';

void main() {
  group('ProcessRunShell', () {
    late IShell shell;

    setUp(() {
      shell = ProcessRunShell();
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
          () async => await shell.withThrowOnError().run('exit 1'),
          throwsA(TypeMatcher<ChassisShellException>()),
        );

        var actual = await shell.withThrowOnError(false).run('exit 1');
        expect(actual.exitCode, equals(1));
      });

      test('runs with the supplied environment', () async {
        var param = Platform.isWindows ? '%findThisValue%' : '\$findThisValue';
        var env = {'findThisValue': '12345'};
        var withEnvironment = shell.withEnvironment(env);

        var actualWithEnvironment = await withEnvironment.run('echo $param');

        var actualWithParam = await withEnvironment
            .run('echo $param', environment: {'findThisValue': '6789'});

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
    });
  });
}
