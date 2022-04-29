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

Parser<B> liftP<A1, B>(Parser<B Function(A1)> fn, Parser<A1> a) =>
    fn.bind<B>((fn) => a.map((a) => fn(a)));

extension ParserApply<U, T> on Parser<U Function(T)> {
  Parser<U> apply(Parser<T> arg) => liftP(this, arg);
  Parser<U> operator <<(Parser<T> arg) => apply(arg);
}

extension ParserE<T> on Parser<T> {
  Parser<T1> map<T1>(T1 Function(T) fn) => bind((val) => returnP(fn(val)));

  Parser<T1> bind<T1>(Parser<T1> Function(T) next) => bindP(this, next);

  Parser<T> operator |(Parser<T> p) => parseOr(this, p);
  Parser<T> where(Predicate<T> p) => matching(this, p);
  Parser<T1> followedBy<T1>(Parser<T1> p) => prefix(this, p);
  Parser<T> prefixedBy(Parser<void> p) => prefix(p, this);
}

Reply<T> runP<T>(
  Parser<T> parser,
  ParseState initialState,
) =>
    parser(initialState).visit(
      consumed: (reply) => reply,
      empty: (reply) => reply,
    );

// bindP :: Parser a -> (a -> Parser b) -> Parser b
Parser<B> bindP<A, B>(
  Parser<A> p,
  Fn1<Parser<B>, A> f,
) =>
    (input) => p(input).visit<ConsumedData<B>>(
          // case (reply1) of
          //   Ok x rest -> ((f x) rest)
          //   Error -> Empty Error
          empty: (reply1) => reply1.visit(
            b: (xAndRest) => f(xAndRest.left)(xAndRest.right),
            a: (error) => Empty(Reply.left(error)),
          ),
          //  case (reply1) of
          //   Ok x rest
          //     -> case ((f x) rest) of
          //     Consumed reply2 -> reply2
          //       Empty reply2 -> reply2
          //   error -> error
          consumed: (reply1) => reply1.visit(
            b: (xAndRest) {
              final x = xAndRest.left;
              final rest = xAndRest.right;
              return f(x)(rest).visit(
                consumed: (reply2) => Consumed(reply2),
                empty: (reply2) => Empty(reply2),
              );
            },
            a: (error) => Empty(Reply.left(error)),
          ),
        );

// returnP :: a -> P a
// returnP a = \s -> Ok a
Parser<A> returnP<A>(A a) => (input) => Consumed(Reply.right(Ok(a, input)));

// failP :: String -> P a
// failP err = \s -> Failed err
Parser<A> failP<A>(ParseError err) => (input) => Empty(Reply.left(err));

// catchP :: P a -> (String -> P a) -> P a
Parser<A> catchP<A>(Parser<A> p, Fn1<Parser<A>, ParseError> k) =>
    (input) => p(input).visit(
          consumed: (reply) => reply.visit(
            a: (err) => k(err)(input),
            b: (suc) => Consumed(Reply.right(suc)),
          ),
          empty: (reply) => reply.visit(
            a: (err) => k(err)(input),
            b: (suc) => Empty(Reply.right(suc)),
          ),
        );
