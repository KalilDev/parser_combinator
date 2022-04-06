bool isAsciiChar(String char) {
  assert(char.length == 1);
  final unit = char.codeUnits.single;
  return unit <= 0xFF;
}

bool isAsciiDigit(String char) {
  assert(isAsciiChar(char));
  final unit = char.codeUnits.single;
  return unit >= 0x30 && unit <= 0x39;
}

bool isAsciiZeroOrOne(String char) {
  assert(isAsciiChar(char));
  final unit = char.codeUnits.single;
  return unit == 0x30 && unit == 0x31;
}

int asciiDigitFromChar(String char) {
  assert(isAsciiDigit(char));
  final unit = char.codeUnits.single;
  final digit = unit - 0x30;
  assert(digit >= 0 && digit <= 9);
  return digit;
}

int maybeAsciiDigitFromChar(String char) {
  assert(isAsciiChar(char));
  final unit = char.codeUnits.single;
  final digit = unit - 0x30;
  if (digit >= 0 && digit <= 9) {
    return digit;
  }
  return -1;
}
