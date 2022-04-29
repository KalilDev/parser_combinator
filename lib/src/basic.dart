import 'package:parser_combinator/parser.dart';
import 'package:parser_combinator/src/predicates.dart';
import 'package:utils/utils.dart';

import 'parser_monad.dart';

import 'combinator.dart';
import 'type.dart';

// ignore: prefer_function_declarations_over_variables
final Parser<int> codeUnit = (state, line) => state.getFirstUnit();
final Parser<String> char = codeUnit.map(String.fromCharCode);

final Parser<int> readCodeUnit = modifyP<int>((state) {
  if (state.left.isEmpty) {
    return state;
  }
  var linecount = state.right;
  final unit = state.left.firstCodeUnit();
  const newLineCodeUnit = 0x0a;
  if (unit == newLineCodeUnit) {
    linecount += 1;
  }
  return Tuple(state.left.next(), linecount);
})(codeUnit);

final Parser<String> readChar = readCodeUnit.map(String.fromCharCode);

Parser<int> exactCodeUnit(int target) =>
    codeUnit.where((result) => result == target);

Parser<String> exactChar(String singleCharString) {
  assert(singleCharString.length == 1);
  return exactCodeUnit(singleCharString.codeUnitAt(0)).map(String.fromCharCode);
}

final Parser<int> asciiCodeUnit = codeUnit.where(isAsciiChar);
final Parser<String> asciiChar = asciiCodeUnit.map(String.fromCharCode);

Parser<int> asciiCodeUnitInRange(int begin, int end) =>
    codeUnit.where((unit) => begin < unit && unit < end);
Parser<String> asciiCharInRange(int begin, int end) =>
    asciiCodeUnitInRange(begin, end).map(String.fromCharCode);

Parser<int> oneOfUnits(Set<int> units) => codeUnit.where(units.contains);
Parser<String> oneOfChars(Set<String> chars) {
  assert(chars.every((c) => c.length == 1));
  return char.where(chars.contains);
}

Parser<T> assignCharToValue<T>(String targetChar, T value) =>
    exactChar(targetChar).map((_) => value);

Parser<T> assignOneOfCharsToValue<T>(Set<String> targetChars, T value) =>
    oneOfChars(targetChars).map((_) => value);

Parser<T> prefix<T>(Parser<void> prefix, Parser<T> p) => prefix.bind((_) => p);
