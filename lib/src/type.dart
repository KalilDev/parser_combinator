import 'package:utils/curry.dart';
import 'package:utils/either.dart';
import 'package:utils/maybe.dart';
import 'package:utils/type.dart';

// So that string view can return
import 'parser_monad.dart';

part 'basic_string_view.dart';

ParseState parseStateFromString(String s) => _StringView.fromString(s);
typedef ParseError = Exception;
// Do NOT use this knowledge. An parser is an parser. It is opaque.
typedef ParseState = _StringView;
typedef Ok<A> = Tuple<A, ParseState>;
//data Reply a = Ok a String | Error
typedef Reply<A> = Either<ParseError, Ok<A>>;

typedef Predicate<T> = bool Function(T);

//data Consumed a = Consumed (Reply a)
// | Empty (Reply a)
abstract class ConsumedData<A> {
  const ConsumedData._();
  const factory ConsumedData.consumed(Reply<A> value) = Consumed;
  const factory ConsumedData.empty(Reply<A> value) = Empty;
  R visit<R>({
    required Fn1<R, Reply<A>> consumed,
    required Fn1<R, Reply<A>> empty,
  });
}

class Empty<A> extends ConsumedData<A> {
  final Reply<A> value;
  const Empty(this.value) : super._();

  R visit<R>({
    required Fn1<R, Reply<A>> consumed,
    required Fn1<R, Reply<A>> empty,
  }) =>
      empty(value);
}

class Consumed<A> extends ConsumedData<A> {
  final Reply<A> value;
  const Consumed(this.value) : super._();

  R visit<R>({
    required Fn1<R, Reply<A>> consumed,
    required Fn1<R, Reply<A>> empty,
  }) =>
      consumed(value);
}

// type Parser a = String → Consumed a
typedef Parser<A> = Fn1<ConsumedData<A>, ParseState>;
