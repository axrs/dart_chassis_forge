If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & dart.exe pub get | Out-Null
}
& dart.exe run bin/build.dart --directory example --main example/main.dart --executable-target kernel | Out-Null
& dart.exe run example/main.dill @args
