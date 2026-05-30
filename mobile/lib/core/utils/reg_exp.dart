/// Non-instantiable static namespace for shared `RegExp` constants used in form
/// validation and input checks across the PantryChef app. The private `_()`
/// constructor enforces non-instantiability; callers reference members via
/// `RegExps.email`, not `RegExps().email`. Only application-wide validation
/// rules belong here; keep module-specific patterns with their own module.
class RegExps {
  RegExps._();

  /// Basic-shape email-validation pattern of the form `local@domain.tld`: one or
  /// more non-`@` characters (local part), a single `@`, one or more non-`@`
  /// characters (domain), a literal `.`, then one or more non-`@` characters (TLD).
  ///
  /// Does NOT support quoted local parts, IP-literal hosts (e.g.
  /// `user@[192.168.1.1]`), or internationalized (Unicode) domain names. Used by
  /// `get_email_error_text.dart` and the auth forms (login, signup) for validation.
  static RegExp email = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
}
