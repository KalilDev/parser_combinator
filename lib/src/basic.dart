import 'parser_monad.dart';

import 'combinator.dart';
import 'type.dart';

ParseOutput<String> char(ParseState state) => state.consumeChar();

Parser<String> character(String target) =>
    matching(char, (result) => result == target);

Parser<String> asciiCharacter() =>
    matching(char, (result) => result.codeUnits.single <= 0xFF);

Parser<String> asciiCharacterInRange(int begin, int end) =>
    matching(char, (result) {
      final unit = result.codeUnits.single;
      return begin < unit && unit < end;
    });

Parser<String> oneOfCharacters<T>(Set<String> targets) =>
    matching(char, targets.contains);

Parser<T> characterMatching<T>(String char, T value) =>
    character(char).map((_) => value);

Parser<T> oneOfCharacterMatching<T>(Set<String> chars, T value) =>
    oneOf(char, chars).map((_) => value);

Parser<T> prefixed<T>(Parser<void> prefix, Parser<T> p) =>
    prefix.bind((_) => p);
