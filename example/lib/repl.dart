import 'dart:convert';
import 'dart:io';

import 'package:example/parser.dart';
import 'package:parser_combinator/parser.dart';
import 'package:utils/curry.dart';
import 'lambda_calculus.dart';
import 'ast.dart';

typedef Enviroment = Map<Identifier, Expr>;

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

Future<void> main() {
  const id_ =
      Let(Identifier('id'), [Identifier('x')], Expr.va(Identifier('x')));
  const true_ = Let(Identifier('true'), [],
      Expr.abs([Identifier('t'), Identifier('f')], Expr.va(Identifier('t'))));
  const false_ = Let(Identifier('false'), [],
      Expr.abs([Identifier('t'), Identifier('f')], Expr.va(Identifier('f'))));
  //Y = λf.(λx.f (x x)) (λx.f (x x))
  const Y_ = Let(
      Identifier('Y'),
      [Identifier('f')],
      Expr.appl(
          // (λx.f (x x))
          Expr.abs(
              [Identifier('x')],
              Expr.appl(
                  Expr.va(Identifier('f')),
                  Expr.appl(
                      Expr.va(Identifier('x')), Expr.va(Identifier('x'))))),

          // (λx.f (x x))

          Expr.abs(
              [Identifier('x')],
              Expr.appl(
                  Expr.va(Identifier('f')),
                  Expr.appl(
                      Expr.va(Identifier('x')), Expr.va(Identifier('x')))))));

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

Future<String> read() {
  // TODO:
  return stdin.transform(utf8.decoder).first;
}

// These functions are marked as async in order to represent the side effects and to
// allow async io in them.
Future<Enviroment> repl_next(Enviroment env) async {
  // side effect!!
  final input = await read();
  final parseResult = runParser(parseLetOrExpr, input).left;
  return parseResult.visit(
    a: (err) async {
      // Another side effect.
      print("Error reading input:");
      print(err);
      return env;
    },
    b: (letOrExpr) async => letOrExpr.visit(
      a: repl_next_from_let.curry(env),
      b: repl_next_from_expr.curry(env),
    ),
  );
}

Enviroment add_let_to_enviroment(
  Enviroment initial_enviroment,
  Let let,
) =>
    Enviroment.of(initial_enviroment)..addEntries([letAsEnviromentEntry(let)]);

Future<Enviroment> repl_next_from_let(
  Enviroment initial_enviroment,
  Let let,
) {
  Enviroment new_env = add_let_to_enviroment(initial_enviroment, let);
  return repl_next(new_env);
}

Enviroment enviromentForBodyOf(Abs abs, Enviroment env) {
  final newEnv = Enviroment.of(env);
  for (final arg in abs.args) {
    newEnv.remove(arg);
  }
  for (final arg in abs.args) {
    newEnv[arg] = Expr.va(arg);
  }
  return newEnv;
}

Expr rewriteInEnv(Expr expr, Enviroment env) => expr.visit(
      appl: (appl) =>
          Expr.appl(rewriteInEnv(appl.fn, env), rewriteInEnv(appl.arg, env)),
      va: (va) => env[va.id] ?? va,
      abs: (abs) => Expr.abs(
        abs.args,
        rewriteInEnv(
          abs.body,
          enviromentForBodyOf(abs, env),
        ),
      ),
    );

bool isNormalForm(Expr expr, Enviroment env) {
  final first = rewriteInEnv(expr, {});
  final second = rewriteInEnv(first, {});
  return first == second;
}

Expr inNormalForm(Expr expr, Enviroment env, [int itCount = 0]) {
  if (isNormalForm(expr, env)) {
    return expr;
  }
  if (itCount > 10) {
    print('it count: $itCount');
  }
  final attempt = rewriteInEnv(expr, {});
  return inNormalForm(attempt, env, itCount + 1);
}

Expr evalInEnviroment(Expr expr, Enviroment env) => inNormalForm(expr, env);

Future<Enviroment> repl_next_from_expr(
  Enviroment currEnv,
  Expr expr,
) {
  final result = evalInEnviroment(expr, currEnv);
  if (result == const Expr.va(Identifier('env'))) {
    print(currEnv);
  } else {
    print(result);
  }
  return repl_next(currEnv);
}
