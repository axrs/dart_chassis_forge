# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
