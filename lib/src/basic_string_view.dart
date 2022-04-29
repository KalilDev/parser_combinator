part of 'type.dart';

abstract class _ParserStateTraits {
  const _ParserStateTraits();
  Reply<int> getFirstUnit();
  ConsumedData<int> consumeUnit();
}

class _StringView extends _ParserStateTraits {
  final String source;
  final int start;
  final int end;

  const _StringView(this.source, this.start, this.end)
      : assert(0 <= start && start <= end && end <= source.length);
  const _StringView.fromString(this.source)
      : start = 0,
        end = source.length;

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
  Reply<int> getFirstUnit() => isEmpty
      ? Reply.left(ParseError("No more chars in '$this'"))
      : Reply.right(Ok(source.codeUnitAt(start), next()));

  @override
  ConsumedData<int> consumeUnit() => isEmpty
      ? Empty(Reply.left(ParseError("No more chars in '$this'")))
      : Consumed(Reply.right(Ok(source.codeUnitAt(start), next())));

  int get hashCode => Object.hash(source, start, end);

  bool operator ==(other) =>
      other is _StringView &&
      ((source == other.source && start == other.start && end == other.end) ||
          (toString() == other.toString()));

  String toString() => source.substring(start, end);
}
