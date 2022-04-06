import 'package:utils/either.dart';
import 'package:utils/type.dart';

typedef ParseError = Exception;
typedef ParseState = String;
typedef ParseResult<T> = Either<ParseError, T>;
typedef ParseOutput<T> = Tuple<ParseResult<T>, ParseState>;
typedef Parser<T> = ParseOutput<T> Function(ParseState);
