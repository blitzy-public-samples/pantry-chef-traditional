/// Non-instantiable shared namespace of reusable regular-expression
/// constants. The private constructor `RegExps._()` prevents instantiation.
///
/// Source: mobile/lib/core/utils/reg_exp.dart:L1-L2
class RegExps {
  RegExps._();

  /// Basic email-shape validation pattern (`^[^@]+@[^@]+\.[^@]+$`) reused
  /// across forms and input checks.
  ///
  /// Source: mobile/lib/core/utils/reg_exp.dart:L4
  static RegExp email = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
}
