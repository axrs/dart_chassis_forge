# Chassis Forge

Chassis Forge is a foundation for building modern CLI apps and tools to help with project automation and other various
tasks. Built on the wonderful [Smart Arg](https://github.com/jcowgar/smart_arg) package.

> Chassis: is the load-bearing framework of an artificial object, which structurally supports the object in its construction and function.

> Forge: create (something) strong, enduring, or successful.

***

## Foundation

Chassis Forge is built on the solid work of [Smart Arg](https://github.com/jcowgar/smart_arg). `Smart Arg` does all the
command line heavy lifting, argument parsing, and help doc generation.

> Note: Chassis Forge uses a parallel fork of `Smart Arg` available [here](https://github.com/axrs/smart_arg?tree=master-forked). This fork adds some additional functionality and helpers
> not currently available in the base `Smart Arg`.

## Getting Started

1. Make sure Dart is installed
1. <https://dart.dev/get-dart>
1. Create (or update) the `pubspec.yaml` file and add `chassis_forge` under `dev_dependencies`

```yaml
name: my_forge
version: 0.0.1
publish_to: none

environment:
  sdk: '>=2.12.0 <3.0.0'

dev_dependencies:
  chassis_forge: "^1.0.0"
```

1. Run `dart pub get` to download the dependency
1. Run `dart run chassis_forge:kindle` to bootstrap your setup

```text
Laying down kindling for Chassis Forge
Where should the Chassis Forge tools be placed <tool>:
What will the name of the entry command <main.dart>:
How would you like the Forge to be welded? <kernel>:

Do you wish to proceed laying kindling?
        with a base directory of: tool
        and a main tool path of: tool/main.dart
        and an execution target of: kernel
Continue Y/N? Y
```

1. Run `./<dir_name>.ps1` (for PowerShell) or `./<dir_name>.sh` (for Bash) to invoke your CLI
1. Modify you commands within the specified directory (defaults to `tool`)

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
import 'package:chassis_forge/chassis_forge.dart';
import 'package:chassis_forge/chassis_forge_dart.dart' as chassis_dart;
import 'package:chassis_forge/smart_arg.dart';

// ignore: unused_import
import 'analyze_command.reflectable.dart';

const String docDescription = 'Generates HTML documentation for the project';

@SmartArg.reflectable
@Parser(
  description: docDescription,
)
class DocCommand extends ChassisCommand with HelpArg {
  @override
  Future<void> run(final IShell shell, final SmartArg parentArguments) async {
    await chassis_dart.doc(shell);
  }
}
```

### More Examples

* [Chassis Forge Tools](https://github.com/axrs/dart_chassis_forge/tree/master/example)
* [Rucksack](https://github.com/axrs/dart_rucksack/tree/master/tool)
* [Anvil](https://github.com/axrs/anvil/tree/master/tool)

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

***

## Recommend Reading

* [10 Design Principles for Delightful CLIs - Atlassian](https://blog.developer.atlassian.com/10-design-principles-for-delightful-clis/)
* [12 Factor CLI Apps - @jdxcode](https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46)

## Related Projects

There are soo many great framework tools out there:

* [oclif](https://oclif.io)
* [picocli](https://picocli.info)
* [CommandDotNet](https://commanddotnet.bilal-fazlani.com)
* [CliFx](https://github.com/Tyrrrz/CliFx)
