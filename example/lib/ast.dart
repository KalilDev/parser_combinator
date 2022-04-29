import 'package:utils/curry.dart';
import 'package:collection/collection.dart';

class Identifier {
  final String name;
  const Identifier(this.name);

  @override
  int get hashCode => name.hashCode;
  @override
  bool operator ==(other) =>
      identical(this, other) || other is Identifier && other.name == name;
  @override
  String toString() => name;
}

class SumType implements Type {
  final List<Type> options;
  const SumType(this.options);

  static const _typeListEq = ListEquality<Type>();

  @override
  int get hashCode => _typeListEq.hash(options);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is SumType && _typeListEq.equals(options, other.options);
  @override
  String toString() =>
      options.map((e) => e is SumType ? '($e)' : e.toString()).join(' | ');
}

abstract class Expr {
  const Expr._();
  const factory Expr.va(Identifier id) = Var._;
  const factory Expr.appl(Expr fn, Expr arg) = Appl._;
  const factory Expr.abs(List<Identifier> args, Expr body) = Abs._;

  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Var> va,
  });
  @override
  Type get runtimeType => const SumType([Var, Appl, Abs]);
  @override
  int get hashCode;
  @override
  bool operator ==(other);
  @override
  String toString();
}

class Var extends Expr {
  final Identifier id;

  const Var._(this.id) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Var> va,
  }) =>
      va(this);
  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(other) => other is Var && id == other.id;
  @override
  String toString() => id.toString();
}

class Appl extends Expr {
  final Expr fn;
  final Expr arg;

  const Appl._(this.fn, this.arg) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Var> va,
  }) =>
      appl(this);

  @override
  int get hashCode => Object.hash(fn, arg);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Appl && other.fn == fn && other.arg == arg;

  @override
  String toString() => '($fn $arg})';
}

const _identifierListEq = ListEquality<Identifier>();

class Abs extends Expr {
  final List<Identifier> args;
  final Expr body;

  const Abs._(this.args, this.body) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Var> va,
  }) =>
      abs(this);

  @override
  int get hashCode => Object.hash(_identifierListEq.hash(args), body);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Abs &&
          _identifierListEq.equals(args, other.args) &&
          body == other.body;

  @override
  String toString() => '(λ${args.join(' ')}. $body)';
}

class Let {
  final Identifier name;
  final List<Identifier> args;
  final Expr body;

  const Let(this.name, this.args, this.body);

  @override
  int get hashCode => Object.hash(name, _identifierListEq.hash(args), body);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is Let &&
          name == other.name &&
          _identifierListEq.equals(args, other.args) &&
          body == other.body;

  @override
  String toString() => 'let $name ${args.join(' ')} = $body';
}
