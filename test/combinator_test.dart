import 'package:parser_combinator/parser.dart';
import 'package:test/test.dart';
import 'package:utils/utils.dart';
import 'utils.dart';

void main() {
  test('both', () {
    final parser = parseBoth(readChar, readChar);
    expectParserSuccess(parser, '12', Tuple('1', '2'));
    expectParserFailure(parser, '', anything);
    expectParserFailure(parser, '1', anything);
  });
}
