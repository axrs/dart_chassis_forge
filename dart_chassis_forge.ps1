If(!(test-path '.dart_tool') -Or -not(Test-Path -Path 'pubspec.lock' -PathType Leaf))
{
    & 'dart.exe' 'pub' 'get'
}
& 'dart.exe' 'run' 'bin/build.dart' 'example'
& 'dart.exe' 'run' 'example/entry_command.dart' @args
