import 'package:parser_combinator/parser.dart';
import 'package:utils/utils.dart';

import 'combinator.dart';
import 'type.dart';

extension ParseErrorE on ParseError {}

/*extension ParseStateE on String {
  ParseOutput<int> consumeUnit() => isEmpty
      ? errorResult(Exception("Reached EOF"), this)
      : success(codeUnitAt(0), substring(1));
}*/

extension OptionalParseResultE<T> on ParseOutput<T> {
  ParseOutput<T1> mapResult<T1>(T1 Function(T) fn) =>
      first((result) => result.fmap(fn));
}

Parser<B> lift<A1, B>(Parser<B Function(A1)> fn, Parser<A1> a) =>
    fn.bind<B>((fn) => a.map((a) => fn(a)));

extension ParserApply<U, T> on Parser<U Function(T)> {
  Parser<U> apply(Parser<T> arg) => lift(this, arg);
  Parser<U> operator <<(Parser<T> arg) => apply(arg);
}

extension ParserE<T> on Parser<T> {
  Parser<T1> map<T1>(T1 Function(T) fn) => bind((val) => returnP(fn(val)));

  Parser<T1> bind<T1>(Parser<T1> Function(T) next) => thenP(this, next);

  Parser<T> operator |(Parser<T> p) => parseOr(this, p);
  Parser<T> where(Predicate<T> p) => matching(this, p);
  Parser<T1> followedBy<T1>(Parser<T1> p) => prefix(this, p);
  Parser<T> prefixedBy(Parser<void> p) => prefix(p, this);
}

ParseResult<T> runParser<T>(
  Parser<T> parser,
  ParseState initialState,
  int line,
) =>
    parser(initialState, line);

ParseOutput<T> errorResult<T>(ParseError error, ParseState state) =>
    Tuple(Left(error), state);
ParseResult<T> successResult<T>(T value) => Right(value);
ParseOutput<T> output<T>(ParseResult<T> result, ParseState state) =>
    Tuple(result, state);

ParseOutput<T> success<T>(T result, ParseState state) =>
    Tuple(successResult(result), state);

Parser<Never> fail(ParseError error) => failP(error);
Parser<T> failure<T>(ParseError error) => failP(error);

Parser<T> pure<T>(T value) => returnP(value);
