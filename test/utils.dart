import 'package:parser_combinator/parser.dart';
import 'package:test/test.dart';
import 'package:test/test.dart' as t;
import 'package:utils/utils.dart';

Never _catchFire([_]) => t.fail('catching fire, oh noooo');

void expectParserSuccess<A>(
  Parser<A> parser,
  String input,
  dynamic output,
) {
  final result = runP(parser, parseStateFromString(input));
  expect(result.maybeLeft, None<ParseError>());
  final actualResult = result.maybeRight.valueOrGet(_catchFire);
  final actualOut = actualResult.left;
  expect(actualOut, output);
}

void expectParserFailure<A>(
  Parser<A> parser,
  String input,
  dynamic failure,
) {
  final result = runP(parser, parseStateFromString(input));
  expect(result.maybeRight, None<Ok<A>>());
  final actualFailure = result.maybeLeft.valueOrGet(_catchFire);
  expect(actualFailure, failure);
}
