If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart pub get | Out-Null
}
& dart run chassis_forge:build --directory example --main example/main.dart --executable-target kernel --verbose | Out-Null
& dart run example/main.dill @args
