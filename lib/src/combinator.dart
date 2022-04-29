// initialState do
// a <- aParser
// b <- bParser
// return (a,b)
//
// Tuple << a << b
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

final Parser<Tuple<ParseState, int>> readP =
    (s, l) => ParseResult.right(Tuple(s, l));

Fn1<Parser<A>, Parser<A>> writeP<A>(ParseState state, int line) =>
    (p) => (_, __) => p(state, line);

Fn1<Parser<A>, Parser<A>> modifyP<A>(
  Tuple<ParseState, int> Function(Tuple<ParseState, int>) mutate,
) =>
    (p) => (s, l) {
          final newState = mutate(Tuple(s, l));
          return p(newState.left, newState.right);
        };

Parser<Tuple<A, B>> parseBoth<A, B>(Parser<A> a, Parser<B> b) =>
    pure(Tuple<A, B>.new.curry) << a << b;

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
      (e) => pure([]),
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
