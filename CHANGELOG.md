# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## \[3.0.0]

* \[Breaking] - Minimum SDK version to 2.14.0
* \[Breaking] - Empty and blank strings are preserved in `args` during shell execution
* \[Breaking] - Removed `HelpOption` and `VerboseOption`
* \[Refactor] - Swapped `ChassisForge.afterCommandParse` and `ChassisForge.afterCommandExecute` for async counterparts
* \[Refactor] - Remove the need for specifying `--directory` in helper scripts
* \[Chore] - Bumped minimum `SmartArg` and `Reflectable` versions
* \[Chore] - Removed `rucksack` dependency

## \[2.2.1]

* \[Fix] - Optional `executable-target` when running build
* \[Doc] - Improved doc string

## \[2.2.0]

* \[Feature] - Allow specifying an optional List<String> args to run and pipe
* \[Feature] - Pipe commands, chaining stdout -> stdin until end
* \[Fix] - cmd and run arg array preserves blank spaces
* \[Fix] - commandRun when nested forge
* \[Fix] - kindle generated Powershell to exit correctly if any dart command fails
* \[Fix] - `bin/build.dart` to compile main if missing

## \[2.1.0] - 2022-02-20

* \[Feature] - Export `shellArgument` and `shellArguments` for escaping args
* \[Feature] - Added `HelpArg` and `VerboseArg` mixin
* \[Feature] - Added `IShell.throwsOnError()`
* \[Test] - `ProcessRunShell` Tests
* \[Deprecated] - `HelpOption` and `VerboseOption`
* \[Miscellaneous] - Refactored and broke up internals

## \[2.0.2] - 2022-02-10

* \[Fix] - `ChassisShellException` now include `stdout`

## \[2.0.1] - 2022-01-31

* \[Fix] - `ChassisForge.onUnknownCommand` use of uninitialized `arguments`

## \[2.0.0] - 2022-01-14

* \[Breaking] - `ChassisForge.runWith` is now Async
* \[Breaking] - Removed default Markdown, Dart, and Node.js helpers/wrappers
* \[Enhancement] - Added `ChassisForge.onHelp`
* \[Enhancement] - Added `ChassisForge.onUnknownCommand`
* \[Enhancement] - Added `IShell.isVerbose`

## \[1.2.2] - 2022-01-13

* \[Refactor] - Simpler loggingConfigured flag that can be adjusted at a global level
* \[Refactor] - Capture `ChassisForge.runWith` arguments

## \[1.2.1] - 2022-01-13

* \[Fix] - Configure verbosity and logging after command parse, instead of beforeExecute
* \[Fix] - Static logging configuration flag to prevent configuration of multiple log watchers

## \[1.2.0] - 2022-01-13

* \[Feature] - Support Nesting `ChassisForge` as a `@Command`
* \[Feature] - Scoped IShell Instances
* \[Fix] - Exit with code `0` if `--help` was requested
* \[Chore] - Update analysis and linting rules
* \[Chore] - Update `process_run` to version `0.12.3+1`
* \[Chore] - Update `smart_arg_fork` to minimum version `2.4.0`
* \[Chore] - Remove `get_it` as a dependency

## \[1.1.0] - 2021-12-17

* \[Feature] - Support not throwing on exception
* \[Feature] - Add `stdout` to exception string message for more useful information
* \[Chore] - Update Smart Arg Fork to be '>=2.2.0 <3.0.0'
* \[Chore] - Update example commands
* \[Fix] - Add library tag to SmartArg export helper

## \[1.0.1] - 2021-12-13

* \[Fix] - Kindle Build command recursive call generating analysis options

## \[1.0.0] - 2021-12-13

* \[Breaking] - Swap `smart_arg` for `smart_arg_fork` for easy access to added features
* \[Feature] - Add `package:chassis_forge/smart_arg.dart` proxy export for easier access

## \[0.3.0] - 2021-12-13

* \[Feature] - Add the ability to modify an IShell environment outside of a process run
* \[Feature] - Generate analysis\_options.yaml when using kindle tool
* \[Enhancement] - Use 'tool' instead of 'forge' as the default directory
* \[Fix] - Markdown formatting with remark
* \[Style] - Update Analyzer and lint rules

## \[0.2.0] - 2021-11-23

* \[Feature] - Added `ChassisForge` class as a foundation class to reduce some boilerplate
* \[Feature] - Added `HelpOption` abstract classes to remove lint warnings
* \[Feature] - Added `VerboseOption` abstract classes to remove lint warnings
* \[Feature] - Added `kindle` helper tool to quickly bootstrap new projects
* \[Feature] - Added `kindle` helper tool to quickly bootstrap new projects
* \[Feature] - remark-preset-lint-consistent\@5.1.0 and remark-preset-lint-recommended\@6.1.1 for markdown formatting
* \[Enhancement] - Allow setting log level before run
* \[Enhancement] - Powershell shebang added to kindle script generation
* \[Enhancement] - Locked Remark and plugins to specific versions
* \[Fix] - Improved `build.chassis.yaml` generation to include dart source directories
* \[Fix] - Prevent argument de-expansion when running in bash
* \[Chore] - Added more example links
* \[Chore] - Drop shell script run log level to fine
* \[Chore] - Powershell Shebang added to Helper Script
* \[Chore] - Remove generated documentation for pub publishing
* \[Chore] - Update Forge Helper script to just call dart
* \[Chore] - Updated Readme
* \[Chore] - Updated `reflectable` to version `3.0.4`
* \[Chore] - Use official `smart_arg` 2.0.0 or compatible

## \[0.0.1] - 2021-10-22

* Initial Release
