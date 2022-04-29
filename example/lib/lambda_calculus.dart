import 'package:utils/curry.dart';
import 'ast.dart';

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
              replaceInExprShadowing(appl.arg, assignments),
            ),
            va: (va) => assignments.containsKey(va.id)
                ? replaceInExprShadowing(assignments[va.id]!, assignments)
                : va,
          );
