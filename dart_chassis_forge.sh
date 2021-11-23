#!/usr/bin/env bash
set -euo pipefail
if [ ! -d '.dart_tool' ] || [ ! -f 'pubspec.lock' ];then
  dart pub get >/dev/null
fi
dart run chassis_forge:build --directory example --main example/main.dart --executable-target kernel --verbose >/dev/null
# shellcheck disable=SC2068
dart run example/main.dill "$@"
