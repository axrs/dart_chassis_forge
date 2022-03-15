#!/usr/bin/env pwsh
function Require-Clean-Exit
{
    if ($LastExitCode -ne 0)
    {
        throw "Command failed with exit code $LastExitCode."
    }
}
If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart pub get | Out-Null
    Require-Clean-Exit
}
& dart run chassis_forge:build --main example/main.dart --executable-target kernel --verbose | Out-Null
Require-Clean-Exit
& dart run example/main.dill @args
Require-Clean-Exit
