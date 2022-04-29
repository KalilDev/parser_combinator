part of 'type.dart';

abstract class _ParserStateTraits {
  const _ParserStateTraits();
  ParseOutput<int> consumeUnit();
}

class _StringView extends _ParserStateTraits {
  final String source;
  final int start;
  final int end;

  const _StringView(this.source, this.start, this.end)
      : assert(0 <= start && start <= end && end <= source.length);

  static const empty = _StringView('', 0, 0);

  bool get isEmpty => start == end;

  int get length => end - start;

  int firstCodeUnit() => source.codeUnitAt(start);

  _StringView next() =>
      start == end ? this : _StringView(source, start + 1, end);

  int firstUnitOrNull() => isEmpty
      ? 0x00 // null
      : source.codeUnitAt(start);

  @override
  ParseResult<int> getFirstUnit() => isEmpty
      ? ParseResult.left(ParseError("No more chars in '$this'"))
      : ParseResult.right(source.codeUnitAt(start));

  @override
  ParseOutput<int> consumeUnit() => isEmpty
      ? errorResult(Exception("Reached EOF"), this)
      : success(source.codeUnitAt(start), next());

  int get hashCode => Object.hash(source, start, end);

  bool operator ==(other) =>
      other is _StringView &&
      ((source == other.source && start == other.start && end == other.end) ||
          (toString() == other.toString()));

  String toString() => source.substring(start, end);
}
