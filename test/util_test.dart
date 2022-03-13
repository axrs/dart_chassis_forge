import 'package:chassis_forge/src/util.dart';
import 'package:test/test.dart';

void main() {
  group('Util', () {
    group('buildCmdWithArgs', () {
      test('single command with multiple args', () async {
        var actual = buildCmdWithArgs('echo', [
          'alpha',
          'bravo foxtrot',
          '--delta=gamma',
        ]);
        expect(actual, equals('echo alpha "bravo foxtrot" --delta=gamma'));
      });

      test('empty args are omitted, but blank are preserved', () async {
        var actual = buildCmdWithArgs('echo', [
          '',
          'bravo foxtrot',
          ' ',
          '--delta=gamma',
        ]);
        expect(actual, equals('echo "bravo foxtrot" " " --delta=gamma'));
      });

      test('no args', () async {
        expect(buildCmdWithArgs('echo', null), equals('echo'));
        expect(buildCmdWithArgs('echo', []), equals('echo'));
      });
    });
  });
}
