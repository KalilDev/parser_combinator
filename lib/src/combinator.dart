// initialState do
// a <- aParser
// b <- bParser
// return (a,b)
//
// Tuple << a << b
import 'package:utils/utils.dart';

import 'parser_monad.dart';
import 'type.dart';

Parser<Tuple<A, B>> parseBoth<A, B>(Parser<A> a, Parser<B> b) =>
    pure(Tuple<A, B>.new.curry) << a << b;

class _EitherParserException implements ParseError {
  final ParseError aFailure;
  final ParseError bFailure;

  _EitherParserException(this.aFailure, this.bFailure);
  @override
  String toString() => '_EitherParserException: Cannot match either parser! '
      'The first failed with $aFailure and the second failed with $bFailure';
}

class _OrParserException implements ParseError {
  final ParseError aFailure;
  final ParseError bFailure;

  _OrParserException(this.aFailure, this.bFailure);
  @override
  String toString() => '_OrParserException: Cannot match either parser! '
      'The first failed with $aFailure and the second failed with $bFailure';
}

Parser<T> parseOr<T>(Parser<T> left, Parser<T> right) => left.bindResult(
      (leftResult) => leftResult.visit(
        a: (leftErr) => right.bindResult(
          (rightResult) => rightResult.visit(
            // fail or failure?
            a: _OrParserException.new.curry(leftErr).comp(failure),
            b: pure,
          ),
        ),
        b: pure,
      ),
    );

Parser<Either<A, B>> parseEither<A, B>(Parser<A> left, Parser<B> right) =>
    left.bindResult(
      (leftResult) => leftResult.visit(
        a: (leftErr) => right.bindResult(
          (rightResult) => rightResult.visit(
            // fail or failure?
            a: _EitherParserException.new.curry(leftErr).comp(failure),
            b: Right<A, B>.new.comp(pure),
          ),
        ),
        b: Left<A, B>.new.comp(pure),
      ),
    );

/// Try parsing an [T] with the parser [p]. If it fails, an empty iterable is
/// returned, otherwise an iterable containing just one value is returned
Parser<Iterable<T>> parseZeroOrOne<T>(Parser<T> p) => p.bindResult(
      (result) => result.visit(
        a: (err) => pure([]),
        b: (value) => pure([value]),
      ),
    );

/// Try parsing zero or one [T]
Parser<Iterable<T>> parseZeroOrMore<T>(Parser<T> p) =>
    parseZeroOrOne(p).bind((result) => result.isEmpty
        ? pure(result)
        : parseZeroOrMore(p).map(result.followedBy));

Parser<Iterable<T>> parseOneOrMore<T>(Parser<T> p) =>
    parseZeroOrMore(p).bind((results) => results.isEmpty
        ? failure(ParseError("There wasn't at least one value"))
        : pure(results));

Parser<T> matching<T>(Parser<T> p, Predicate<T> predicate) =>
    p.bind((result) => predicate(result)
        ? pure(result)
        : failure(ParseError("Does not match predicate")));

Parser<T> oneOf<T>(Parser<T> p, Set<T> values) => matching(p, values.contains);
