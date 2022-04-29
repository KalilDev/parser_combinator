import 'package:parser_combinator/parser.dart';
import 'package:test/test.dart';
import 'package:utils/utils.dart';
import 'utils.dart';

void main() {
  group('both', () {
    test('same type', () {
      final parser = parseBoth(char, char);
      expectParserSuccess(parser, '12', Tuple('1', '2'));
      expectParserFailure(parser, '', anything);
      expectParserFailure(parser, '1', anything);
    });
    test('diff type', () {
      final parser = parseBoth(char, codeUnit);
      final codeUnitOfTwo = 50;
      expectParserSuccess(parser, '12', Tuple('1', codeUnitOfTwo));
      expectParserFailure(parser, '', anything);
      expectParserFailure(parser, '1', anything);
    });
  });
}
