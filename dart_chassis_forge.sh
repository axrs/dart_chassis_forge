#!/usr/bin/env bash
set -euo pipefail
if [ ! -d '.dart_tool' ] || [ ! -f 'pubspec.lock' ];then
  dart pub get >/dev/null
fi
dart run bin/build.dart example
# shellcheck disable=SC2068
dart run example/entry_command.dart $@
