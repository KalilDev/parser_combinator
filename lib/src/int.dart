import 'parser_monad.dart';
import 'package:utils/utils.dart';

import 'basic.dart';
import 'combinator.dart';
import 'predicates.dart';
import 'type.dart';

// int_literal ::= radix_int_literal
//               | regular_int_literal
Parser<int> intLiteral = radixIntLiteral | regularIntLiteral;

// radix_int_literal ::= `0` radix_literal
// radix_literal ::= `b` binary_literal
//                 | `x` hex_literal
Parser<int> radixIntLiteral = character('0').followedBy(
  character('b').followedBy(binaryLiteral) |
      character('x').followedBy(hexLiteral),
);

// binary_literal ::= binary_digit+
Parser<int> binaryLiteral =
    parseOneOrMore(binaryDigit).map(_intFromBinaryDigits);

// hex_literal ::= hex_digit+
Parser<int> hexLiteral = parseOneOrMore(hexDigit).map(_intFromHexDigits);

// regular_int_literal ::= maybe_sign digit+
Parser<int> regularIntLiteral =
    pure(_intFromSignAndDigits.curry) << maybeNegSign << parseOneOrMore(digit);

// maybe_neg_sign ::= `-`?
Parser<int> maybeNegSign = characterMatching('-', -1) | pure(1);

// digit ::= `0` | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9`
Parser<int> digit = char.where(isAsciiDigit).map(asciiDigitFromChar);

// binary_digit ::= `0` | `1`
Parser<int> binaryDigit = char.where(isAsciiZeroOrOne).map(asciiDigitFromChar);

// hex_digit ::= digit | a | b | c | d | e | f
// a ::= `A` | `a`
// b ::= `B` | `b`
// c ::= `C` | `c`
// d ::= `D` | `d`
// e ::= `E` | `e`
// f ::= `F` | `f`
Parser<int> hexDigit = digit |
    oneOfCharacterMatching(const {'A', 'a'}, 0xA) |
    oneOfCharacterMatching(const {'B', 'b'}, 0xB) |
    oneOfCharacterMatching(const {'C', 'c'}, 0xC) |
    oneOfCharacterMatching(const {'D', 'd'}, 0xD) |
    oneOfCharacterMatching(const {'E', 'e'}, 0xE) |
    oneOfCharacterMatching(const {'F', 'f'}, 0xF);

int _intFromRadixDigits(Iterable<int> digits, int radix) => digits.fold(
      0,
      (acc, digit) => (acc * radix) + digit,
    );

int _intFromSignAndDigits(int sign, Iterable<int> digits) =>
    sign * _intFromRadixDigits(digits, 10);

int _intFromBinaryDigits(Iterable<int> digits) =>
    _intFromRadixDigits(digits, 2);
int _intFromHexDigits(Iterable<int> digits) => _intFromRadixDigits(digits, 16);
