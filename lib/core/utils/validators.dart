/// Static form validators compatible with [TextFormField.validator].
/// Each method returns `null` when valid or an error string when invalid.
class Validators {
  Validators._();

  static String? required(String? v,
      {String message = 'This field is required'}) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? v,
      {String message = 'Enter a valid email address'}) {
    if (v == null || v.isEmpty) return message;
    final regex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(v.trim()) ? null : message;
  }

  static String? phone(String? v,
      {String message = 'Enter a valid phone number'}) {
    if (v == null || v.isEmpty) return message;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? null : message;
  }

  static String? minLength(String? v, int min, {String? message}) {
    if (v == null || v.length < min) {
      return message ?? 'Minimum $min characters required';
    }
    return null;
  }

  static String? maxLength(String? v, int max, {String? message}) {
    if (v != null && v.length > max) {
      return message ?? 'Maximum $max characters allowed';
    }
    return null;
  }

  static String? password(String? v, {String? message}) {
    if (v == null || v.length < 8) {
      return message ?? 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? v, String? original,
      {String message = 'Passwords do not match'}) {
    if (v != original) return message;
    return null;
  }

  static String? numeric(String? v, {String message = 'Enter a valid number'}) {
    if (v == null || double.tryParse(v) == null) return message;
    return null;
  }

  static String? url(String? v, {String message = 'Enter a valid URL'}) {
    if (v == null || v.isEmpty) return message;
    final uri = Uri.tryParse(v);
    return (uri != null && uri.hasScheme && uri.hasAuthority) ? null : message;
  }

  /// Compose multiple validators — returns the first error found.
  static String? Function(String?) compose(
      List<String? Function(String?)> validators) {
    return (v) {
      for (final fn in validators) {
        final result = fn(v);
        if (result != null) return result;
      }
      return null;
    };
  }
}
