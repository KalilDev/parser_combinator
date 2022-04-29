import 'package:utils/utils.dart';

import 'parser_monad.dart';
import 'type.dart';

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

// initialState do
// a <- aParser
// b <- bParser
// return (a,b)
//
// Tuple << a << b
Parser<Tuple<A, B>> parseBoth<A, B>(Parser<A> a, Parser<B> b) =>
    returnP(Tuple<A, B>.new.curry) << a << b;

Parser<T> parseOr<T>(Parser<T> left, Parser<T> right) => catchP(
      left,
      (leftE) => catchP(
        right,
        (rightE) => failP(
          _OrParserException(leftE, rightE),
        ),
      ),
    );

Parser<Either<A, B>> parseEither<A, B>(Parser<A> left, Parser<B> right) =>
    catchP(
      left.map(Left.new),
      (leftE) => catchP(
        right.map(Right.new),
        (rightE) => failP(
          _EitherParserException(leftE, rightE),
        ),
      ),
    );

/// Try parsing an [T] with the parser [p]. If it fails, an empty iterable is
/// returned, otherwise an iterable containing just one value is returned
Parser<Iterable<T>> parseZeroOrOne<T>(Parser<T> p) => catchP(
      p.map((e) => [e]),
      (e) => returnP([]),
    );

/// Try parsing zero or one [T]
Parser<Iterable<T>> parseZeroOrMore<T>(Parser<T> p) =>
    parseZeroOrOne(p).bind((result) => result.isEmpty
        ? returnP(result)
        : parseZeroOrMore(p).map(result.followedBy));

Parser<Iterable<T>> parseOneOrMore<T>(Parser<T> p) =>
    parseZeroOrMore(p).bind((results) => results.isEmpty
        ? failP(ParseError("There wasn't at least one value"))
        : returnP(results));

Parser<T> matching<T>(Parser<T> p, Predicate<T> predicate) =>
    p.bind((result) => predicate(result)
        ? returnP(result)
        : failP(ParseError("Does not match predicate")));

Parser<T> oneOf<T>(Parser<T> p, Set<T> values) => matching(p, values.contains);
