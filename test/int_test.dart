import 'package:parser_combinator/parser.dart';
import 'package:parser_combinator/src/int.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as t;
import 'package:utils/maybe.dart';

Never _catchFire([_]) => t.fail('catching fire, oh noooo');

void main() {
  test('basic', () {
    final input = parseStateFromString('1');
    final output = 1;
    final parser = digit;
    final result = runParser(parser, input, 0);
    expect(result.maybeLeft, None<Exception>());
    final actualResult = result.maybeRight.valueOrGet(_catchFire);
    expect(actualResult, output);
  });
}
