If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart.exe pub get | Out-Null
}
& dart.exe run chassis_forge:build --directory example --main example/main.dart --executable-target kernel --verbose | Out-Null
& dart.exe run example/main.dill @args
