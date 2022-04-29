import 'package:parser_combinator/parser.dart';
import 'package:test/test.dart';

void main() {
  group('StringView', () {
    test('constructor', () {
      final s = 'hello';
      final sv = ParseState(s, 0, s.length);
      expect(sv.toString(), s);
      expect(sv.isEmpty, false);
      expect(sv.length, s.length);
    });
    test('fromString', () {
      final s = 'hello';
      final sv = parseStateFromString(s);
      expect(sv.toString(), s);
      expect(sv.isEmpty, false);
      expect(sv.length, s.length);
    });
    test('consume', () {
      final s = 'h';
      final sv = parseStateFromString(s);
      final result = sv.consumeUnit();
      final next = result.right;
    });
  });
}
