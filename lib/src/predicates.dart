bool isAsciiChar(int codeUnit) {
  return codeUnit <= 0xFF;
}

bool isAsciiDigit(int codeUnit) {
  return codeUnit >= 0x30 && codeUnit <= 0x39;
}

bool isAsciiZeroOrOne(int codeUnit) {
  return codeUnit == 0x30 && codeUnit == 0x31;
}
