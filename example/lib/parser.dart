import 'package:example/ast.dart';
import 'package:parser_combinator/parser.dart';
import 'package:utils/maybe.dart';
import 'package:utils/curry.dart';
import 'package:utils/either.dart';
import 'lambda_calculus.dart';

bool isAsciiTextChar(String char) {
  final unit = char.codeUnits.single;
  return
      // Start at bang !
      unit >= 0x20 &&
          // End at DEL
          unit < 0x7f
      // TODO: Extended ascii.
      ;
}

final isAsciiWhitespace = const {' ', '\n', '\t'}.contains;
Parser<String> parseCharSequence(String seq) => seq.isEmpty
    ? pure('')
    : char
        .where((c) => c == seq[0])
        .followedBy(parseCharSequence(seq.substring(1)));
final Parser<String> parseWord = char.bind((c) => isAsciiTextChar(c)
    ? parseWord.map((nextC) => c + nextC)
    : isAsciiWhitespace(c)
        ? pure('')
        : fail(Exception('Invalid ascii char passed to parseWord')));
Parser<String> parseKeyword(String keyword) =>
    parseWord.where((w) => w == keyword);

final Parser<Identifier> parseIdentifier = parseWord.map(Identifier.new);
final Parser<List<Identifier>> parseArguments =
    parseOneOrMore(parseIdentifier).map(List.of);

Expr _absFromParts(List<Identifier> args, _dot, Expr body) =>
    Expr.abs(args, body);

final Parser<Expr> parseExprAbs = parseKeyword('\\').followedBy(
    pure(_absFromParts.curry) <<
        parseArguments <<
        parseKeyword('.') <<
        parseExpr);

final Parser<Expr> parseExprAppl =
    pure(Expr.appl.curry) << parseExprOtherThanAppl << parseExpr;

final Parser<Expr> parseExprVa = pure(Expr.va) << parseIdentifier;

// Do this because otherwise we will end up in a loop trying to parse an appl:
// parseExpr -> parseAppl -> parseExpr -> parseAppl.
// now it is this:
// parseExpr -> parseAppl -> parseExprOtherThanAppl -> parseVa | parseAbs ... -> parseExpr -> done.
final Parser<Expr> parseExprOtherThanAppl = parseExprVa | parseExprAbs;

final Parser<Expr> parseExpr = parseExprAppl | parseExprOtherThanAppl;

Let _letFromParts(Identifier name, Iterable<List<Identifier>> maybeArgs, _eq,
        Expr body) =>
    Let(name, maybeArgs.isEmpty ? const [] : maybeArgs.single, body);

final Parser<Let> parseLet = parseKeyword('let').followedBy(
    pure(_letFromParts.curry) <<
        parseIdentifier <<
        parseZeroOrOne(parseArguments) <<
        parseKeyword('=') <<
        parseExpr);

final parseLetOrExpr = parseEither(parseLet, parseExpr);
