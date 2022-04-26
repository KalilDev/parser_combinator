typedef Fn1<R, T> = R Function(T);

abstract class Expr {
  const Expr._();
  const factory Expr.id(Identifier id) = Id._;
  const factory Expr.appl(Expr fn, List<Expr> args) = Appl._;
  const factory Expr.abs(List<Identifier> args, Expr body) = Abs._;

  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Id> id,
  });
  @override
  int get hashCode;
  @override
  bool operator ==(other);
  @override
  String toString();
}

class Id extends Expr {
  final Identifier id;

  const Id._(this.id) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Id> id,
  }) =>
      id(this);
  @override
  String toString() => id.toString();
}

class Appl extends Expr {
  final Expr fn;
  final List<Expr> args;

  const Appl._(this.fn, this.args) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Id> id,
  }) =>
      appl(this);

  @override
  String toString() => '($fn ${args.join(' ')})';
}

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

class Abs extends Expr {
  final List<Identifier> args;
  final Expr body;

  const Abs._(this.args, this.body) : super._();

  @override
  R visit<R>({
    required Fn1<R, Appl> appl,
    required Fn1<R, Abs> abs,
    required Fn1<R, Id> id,
  }) =>
      abs(this);

  @override
  String toString() => '(λ${args.join(' ')}. $body)';
}

class Let {
  final Identifier name;
  final List<Identifier> args;
  final Expr body;

  const Let(this.name, this.args, this.body);

  @override
  String toString() => 'let $name ${args.join(' ')} = $body';
}

Expr replaceInExprShadowing(
  Expr body,
  Map<Identifier, Expr> assignments,
) =>
    assignments.isEmpty
        ? body
        : body.visit(
            abs: (abs) => Expr.abs(
              abs.args,
              replaceInExprShadowing(
                abs.body,
                // if \x. \x. x, do not replace the x from the outer into the inner. aka shadowing
                Map.of(assignments)
                  ..removeWhere(
                    (key, _) => abs.args.contains(key),
                  ),
              ),
            ),
            appl: (appl) => Expr.appl(
              replaceInExprShadowing(appl.fn, assignments),
              appl.args
                  .map((expr) => replaceInExprShadowing(expr, assignments))
                  .toList(),
            ),
            id: (id) => assignments.containsKey(id.id)
                ? replaceInExprShadowing(assignments[id.id]!, assignments)
                : id,
          );

MapEntry<Identifier, Expr> letAsEnviromentEntry(Let let) => MapEntry(
      let.name,
      // feels wrong
      let.args.isEmpty
          ? let.body
          : Expr.abs(
              let.args,
              let.body,
            ),
    );

typedef Enviroment = Map<Identifier, Expr>;
Future<void> main() {
  const id_ =
      Let(Identifier('id'), [Identifier('x')], Expr.id(Identifier('x')));
  const true_ = Let(Identifier('true'), [],
      Expr.abs([Identifier('t'), Identifier('f')], Expr.id(Identifier('t'))));
  const false_ = Let(Identifier('false'), [],
      Expr.abs([Identifier('t'), Identifier('f')], Expr.id(Identifier('f'))));
  //Y = λf.(λx.f (x x)) (λx.f (x x))
  const Y_ = Let(
      Identifier('Y'),
      [Identifier('f')],
      Expr.appl(
          // (λx.f (x x))
          Expr.abs(
              [Identifier('x')],
              Expr.appl(Expr.id(Identifier('f')), [
                Expr.appl(Expr.id(Identifier('x')), [Expr.id(Identifier('x'))])
              ])),

          // (λx.f (x x))
          [
            Expr.abs(
                [Identifier('x')],
                Expr.appl(Expr.id(Identifier('f')), [
                  Expr.appl(
                      Expr.id(Identifier('x')), [Expr.id(Identifier('x'))])
                ]))
          ]));

  const initialEnviromentLets = [
    id_,
    true_,
    false_,
    Y_,
  ];
  final Enviroment initialEnviroment =
      Map.fromEntries(initialEnviromentLets.map(letAsEnviromentEntry));

  print(initialEnviroment);

  return repl_next(initialEnviroment);
}

Future<Enviroment> repl_next(Enviroment env) {
  final input = read();
  final either_let_or_expr = parse(input);
  return either_let_or_expr.visit(
    left: repl_next_from_let.curry(env),
    right: repl_next_from_expr.curry(env),
  );
}

Enviroment add_let_to_enviroment(Let let, Enviroment initial_enviroment) =>
    Enviroment.of(initial_enviroment)..addEntries([letAsEnviromentEntry(let)]);

Future<Enviroment> repl_next_from_let(Let let, Enviroment initial_enviroment) {
  Enviroment new_env = add_let_to_enviroment(let, initial_enviroment);
  return repl_next(new_env);
}

Object evalInEnviroment(Expr expr, Enviroment env) {}

Future<Enviroment> repl_next_from_expr(
    Expr expr, Enviroment initial_enviroment) {
  print(evalInEnviroment(expr, initial_enviroment));
  return repl_next(initial_enviroment);
}
