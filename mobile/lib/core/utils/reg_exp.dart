/// Non-instantiable shared namespace of reusable regular-expression
/// constants. The private constructor `RegExps._()` prevents instantiation.
///
class RegExps {
  RegExps._();

  /// Basic email-shape validation pattern (`^[^@]+@[^@]+\.[^@]+$`) reused
  /// across forms and input checks.
  ///
  static RegExp email = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
}
