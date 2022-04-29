import 'package:parser_combinator/parser.dart';
import 'package:test/test.dart';
import 'package:utils/utils.dart';
import 'utils.dart';

void main() {
  test('codeUnit', () {
    final un1 = '1'.codeUnits.single;
    expectParserSuccess(codeUnit, '1', un1);
    expectParserFailure(codeUnit, '', anything);
  });
  test('char', () {
    expectParserSuccess(char, 's', 's');
    expectParserFailure(char, '', anything);
  });
}
