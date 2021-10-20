# Chassis Forge

Chassis Forge is a foundation for building modern CLI apps and tools to help with project automation and other various
tasks.

> Chassis: is the load-bearing framework of an artificial object, which structurally supports the object in its construction and function.

> Forge: create (something) strong, enduring, or successful.

***

## About

In a lot of my day-to-day software development, I'm positioned to run multiple command line utilities in succession
across different code bases and frameworks. For example, I may have to:

* Install Dependencies
  * Which downloads the dependencies
  * Compiles/Builds any sub-modules
  * Move packages into a different directory
* Run unit tests that first need to validate a database version
* Connect to a 3rd party service to query usage information
* Deploy a new version of a service
  * Cleans any existing directories
  * Compiles/Builds any the service
  * Uploads the package to the necessary build system
  * Initiates a blue-green deploy cycle
* ... And soo much more

These types of commands are laborious, time-consuming, human-error prone, painful to keep up to date, and difficult to
share with other team members. Once the process becomes too complex, developers will often look into automation, build
systems, and scripting.

In the past, I have resorted to BASH as my go to... This is all well and good until:

* You need to share code across multiple projects
* You need to perform any form of debugging
* You need to update documentation
* You need the scripts to be run cross-platform
  * Many System Commands treat flags and attributes differently.
    * Such as date between GNU Linux and MacOS Unix
    * and much more in Alpine
  * Windows likely requires WSL... Which is another whole story
* One change in shared code breaks another project months later

As a result of this pain and frustration, I've become passionate about finding a CLI tool/framework that I could use and
adopt across all my projects with minimal frustration and effort. I spent a lot of time playing with each framework
listed in the [Related Projects](#related-projects). Ultimately looking for must, and would be nice to haves.

### Must Have

* Is easy to read and understand
* Cross Platform support with minimal setup and configuration
* Allows quickly scripting without long compilation times
* Share code/libraries in a Semantically Versioned Way
* Provides a consistent logging/output framework with varying levels of verbosity
* Offer finer control over thrown exceptions and errors
* Associates command and flag/argument documentation directly with the command definition
* Support commands, sub-commands, and scripts
* Can Invoke other 3rd party executables
  * Like the `aws` and `azure` CLIs
    * capturing their `stdout` and `stderr` streams
    * easily raising trappable and reportable exceptions
* Support prompting for missing, or more, input
* Speedy
  * At least on subsequent runs
* Is not a task runner, but allows me to combine commands if I wish

### Would be Nice to Have

* Decoupled with Dependency Injection Support
* Unit Testable

***

## Usage

1. Make sure Dart is installed
   1. <https://dart.dev/get-dart>
1. Create (or update) the `pubspec.yaml` file and add `dart_chassis_forge` under `dev_dependencies`
1. Create some commands in a desired location. For example `./tools` or `./bin`

   > Note: Dart uses `bin` for distributing tools within packages.

   1. The [example](example/) directory contains a few commands used for this project including:
      1. [Analyze](example/analyze\_command.dart)
      1. [Doc](example/doc\_command.dart)
      1. [Format](example/format\_command.dart)
   1. (Optional) Create an [Entry](example/entry\_command.dart) point command.
1. Build and run the script:
   > Note: Compilation is only required if the annotations change.
   1. Either Add a [BASH](dart\_chassis\_forge.sh) or [PowerShell](dart\_chassis\_forge.ps1) script as a proxy to:
      1. conveniently install the dart dependencies (if not already done so);
      1. compile the commands on change
      1. invoke the main entry point
   1. OR Run:
      1. `dart run dart_chassis_forge:build` to build the commands
      1. `dart run tool/entry_command.dart <arg> <arg> <arg>` to run your command

### Example Output

```text
$ ./dart_chassis_forge.ps1
Dart Chassis Forge Project Helper Tools


  -v, --verbose  Enable Command Verbose Mode
  -h, --help, -? Show help

COMMANDS
  analyze Runs static code analysis across the code base
  doc Generates HTML documentation for the project
  format Runs the various source code formatting tools
```

```text
$ ./dart_chassis_forge.ps1 analyze
2021-10-19 20:11:58.965568 | INFO    | cf:Dart        : Analyzing...
```

```text
$ ./dart_chassis_forge.ps1 --verbose analyze
2021-10-19 20:13:14.090159 | INFO    | cf:Dart        : Analyzing...
2021-10-19 20:13:14.099159 | FINE    | cf:Shell       : Running: dart analyze
$ dart analyze
Analyzing dart_chassis_forge...
No issues found!
```

### Example Command

```dart
import 'package:dart_chassis_forge/chassis_forge.dart';
import 'package:dart_chassis_forge/chassis_forge_dart.dart' as chassis_dart;
import 'package:smart_arg/smart_arg.dart';

// ignore: unused_import
import 'analyze_command.reflectable.dart';

const String docDescription = 'Generates HTML documentation for the project';

@SmartArg.reflectable
@Parser(
  description: docDescription,
)
class DocCommand extends ChassisCommand {
  @HelpArgument()
  late bool help = false;

  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await chassis_dart.doc(shell);
  }
}
```

### Helper Scripts

The following scripts can be used as an entry point template for re-building, and executing, your commands after a
source code change.

#### Windows

<details>
<summary>Run Script</summary>
<p>

```powershell
If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart.exe pub get
}
& dart.exe dart_chassis_forge:build --directory example | Out-Null
& dart.exe example/entry_command.dart @args
```

</p>
</details>

<details>
<summary>Kernel Compile</summary>
<p>

```powershell
If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart.exe pub get
}
& dart.exe dart_chassis_forge:build --directory example --main example/entry_command.dart --executable-target kernel | Out-Null
& dart.exe example/entry_command.dill @args
```

</p>
</details>

#### Unix Based OS

<details>
<summary>Run Script</summary>
<p>

```shell
#!/usr/bin/env bash
set -euo pipefail
if [ ! -d '.dart_tool' ] || [ ! -f 'pubspec.lock' ];then
  dart pub get >/dev/null
fi
dart dart_chassis_forge:build --directory example >/dev/null
# shellcheck disable=SC2068
dart run tool/entry_command.dart $@
```

</p>
</details>

<details>
<summary>Kernel Compile</summary>
<p>

```shell
#!/usr/bin/env bash
set -euo pipefail
if [ ! -d '.dart_tool' ] || [ ! -f 'pubspec.lock' ];then
  dart pub get >/dev/null
fi
dart dart_chassis_forge:build --directory example --main example/entry_command.dart --executable-target kernel >/dev/null
# shellcheck disable=SC2068
dart example/entry_command.dill $@
```

</p>
</details>

### Rough Performance Benchmarking

When using the convenience scripts defined above, when one of the commands source files has changed, a rebuild of the
reflectables is initiated before invocation. This ensures the documentation, fields, and other properties are
up-to-date.

|                   | Build Sources and Run | Run as Script |
| ----------------- | --------------------- | ------------- |
| Run Script        | 9,923.14ms            | 1,937.93ms    |
| Kernel Compile    | 10,242.65ms           | 884.42ms      |
| Native Executable | N/A                   | 78.13ms       |

If the reflectables are up-to-date, the build process does not need to occur. Reducing the overall run time. It's not
a *bad* result, but there is definitely room for improvement. If speed is king, then a native executable can be
compiled.

Notes:

* A little over half of the runtime relates to checking for outdated build artifacts.
  * Approximately 1/3 of the build check time is Dart starting up. Which can take \~500ms on an empty dart script

## Example within Projects

* [Rucksack](https://github.com/axrs/dart\_rucksack/tree/master/tool)

***

## Recommend Reading

* [10 Design Principles for Delightful CLIs - Atlassian](https://blog.developer.atlassian.com/10-design-principles-for-delightful-clis/)
* [12 Factor CLI Apps - @jdxcode](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)

## Related Projects

There are soo many great framework tools out there:

* [Smart Arg](https://github.com/jcowgar/smart\_arg)
* [oclif](https://oclif.io)
* [picocli](https://picocli.info)
* [CommandDotNet](https://commanddotnet.bilal-fazlani.com)
* [CliFx](https://github.com/Tyrrrz/CliFx)
