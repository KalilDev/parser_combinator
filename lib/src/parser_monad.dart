import 'package:parser_combinator/parser.dart';
import 'package:utils/utils.dart';

import 'combinator.dart';
import 'type.dart';

extension ParseErrorE on ParseError {}

extension ParseStateE on ParseState {
  ParseOutput<String> consumeChar() => isEmpty
      ? errorResult(Exception("Reached EOF"), this)
      : success(this[0], substring(1));
}

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
  Parser<T1> map<T1>(T1 Function(T) fn) =>
      (state) => runParser<T>(this, state).mapResult(fn);

  Parser<T1> mapResult<T1>(T1 Function(ParseResult<T>) fn) =>
      (state) => runParser<T>(this, state).first(fn.comp(Right.new));

  Parser<T1> bind<T1>(Parser<T1> Function(T) next) => (state) {
        final $ = runParser(this, state);
        final result = $.left, rest = $.right;

        return runParser(
          result.visit(
            // TODO: See if i can use fail or need to use failure. fail would be preferrable because it does not need to use the runtime cost of the type arguments
            a: fail,
            b: next,
          ),
          rest,
        );
      };

  Parser<T1> bindResult<T1>(Parser<T1> Function(ParseResult<T>) next) =>
      (state) {
        final $ = runParser(this, state);
        final result = $.left, rest = $.right;

        return runParser(
          next(result),
          rest,
        );
      };

  Parser<T> operator |(Parser<T> p) => parseOr(this, p);
  Parser<T> where(Predicate<T> p) => matching(this, p);
  Parser<T1> followedBy<T1>(Parser<T1> p) => prefixed(this, p);
  Parser<T> prefixedBy(Parser<void> p) => prefixed(p, this);
}

ParseOutput<T> runParser<T>(
  Parser<T> parser,
  ParseState initialState,
) =>
    parser(initialState);

ParseOutput<T> errorResult<T>(ParseError error, ParseState state) =>
    Tuple(Left(error), state);
ParseResult<T> successResult<T>(T value) => Right(value);
ParseOutput<T> output<T>(ParseResult<T> result, ParseState state) =>
    Tuple(result, state);

ParseOutput<T> success<T>(T result, ParseState state) =>
    Tuple(successResult(result), state);

Parser<Never> fail(ParseError error) => (state) => errorResult(error, state);
Parser<T> failure<T>(ParseError error) => (state) => errorResult(error, state);

Parser<T> pure<T>(T value) => (state) => success(value, state);
