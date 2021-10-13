If(!(test-path ".dart_tool") -Or -not(Test-Path -Path "pubspec.lock" -PathType Leaf))
{
    & 'dart.exe' "pub" "get"
}
& 'dart.exe' "run" "bin/build.dart"
& 'dart.exe' "run" "tool/entry_command.dart" @args
