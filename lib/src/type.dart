import 'package:utils/curry.dart';
import 'package:utils/either.dart';
import 'package:utils/maybe.dart';
import 'package:utils/type.dart';

// So that string view can return
import 'parser_monad.dart';

part 'basic_string_view.dart';

ParseState parseStateFromString(String s) => _StringView(s, 0, s.length);

typedef ParseError = Exception;
// Do NOT use this knowledge. An parser is an parser. It is opaque.
typedef ParseState = _StringView;
typedef ParseOutput<T> = Tuple<ParseResult<T>, ParseState>;
//typedef Parser<A> = ParseResult<A> Function(ParseState);
typedef Predicate<T> = bool Function(T);

//data ParseResult a = Ok a | Failed String
typedef ParseResult<A> = Either<ParseError, A>;

// thenP :: P a -> (a -> P b) -> P b
// m `thenP` k = \s ->
//    case m s of
//        Ok a -> k a s
// 	 Failed e -> Failed e
Parser<B> thenP<A, B>(
  Parser<A> m,
  Fn1<Parser<B>, A> k,
) =>
    (s, l) =>
        m(s, l).visit(b: (a) => k(a)(s, l), a: (e) => ParseResult.left(e));

// returnP :: a -> P a
// returnP a = \s -> Ok a
Parser<A> returnP<A>(A a) => (s, l) => ParseResult.right(a);

// failP :: String -> P a
// failP err = \s -> Failed err
Parser<A> failP<A>(ParseError err) => (s, l) => ParseResult.left(err);

// catchP :: P a -> (String -> P a) -> P a
// catchP m k = \s ->
//    case m s of
//       Ok a -> OK a
// 	Failed e -> k e s
Parser<A> catchP<A>(Parser<A> m, Fn1<Parser<A>, ParseError> k) => (s, l) =>
    m(s, l).visit(b: (a) => ParseResult.right(a), a: (e) => k(e)(s, l));
//type LineNumber = Int
typedef LineNumber = int;

//type P a = String -> LineNumber -> ParseResult a
typedef Parser<A> = Fn2<ParseResult<A>, ParseState, LineNumber>;

// getLineNo :: P LineNumber
// getLineNo = \s l -> Ok l
Parser<LineNumber> getLineNo = (s, l) => ParseResult.right(l);

// The token must have an EOF.
abstract class TokenTraits {
  bool get isEOF;
}

//If you want a lexer of type P Token, then just define a wrapper to deal with the continuation:
//lexwrap :: (Token -> P a) -> P a
//lexwrap cont = real_lexer `thenP` \token -> cont token
Parser<A> lexwrap<A, Token extends TokenTraits>(
  Parser<Token> realLexer,
  Fn1<Parser<A>, Token> cont,
) =>
    thenP<Token, A>(realLexer, cont);

//parse      :: P t
typedef ParseFn<T> = Parser<T>;
//parseError :: Token -> P a
typedef ParseErrorFn<A, Token extends TokenTraits> = Fn1<Parser<A>, Token>;
// You can see from this type that the lexer takes a continuation
// as an argument. The lexer is to find the next token, and pass
// it to this continuation to carry on with the parse. Obviously,
// we need to keep track of the input in the monad somehow, so that
// the lexer can do something different each time it's called!
//
// lexer cont s =
//     ... lexical analysis code ...
//     cont token s'
// lexer      :: (Token -> P a) -> P a
typedef LexerFn<A, Token extends TokenTraits>
    = Fn1<Parser<A>, Fn1<Parser<A>, Token>>;
