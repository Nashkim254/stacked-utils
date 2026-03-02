extension StringX on String {
  // ── Case ────────────────────────────────────────────────────────────────

  /// 'hello world' → 'Hello World'
  String get titleCase => split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
      .join(' ');

  /// 'hello world' → 'Hello world'
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  // ── Truncation ───────────────────────────────────────────────────────────

  /// Cuts to [maxLength] chars and appends [ellipsis].
  String truncate(int maxLength, {String ellipsis = '…'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$ellipsis';

  // ── Initials ─────────────────────────────────────────────────────────────

  /// 'John Doe' → 'JD', 'Alice' → 'A'
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // ── Masking ──────────────────────────────────────────────────────────────

  /// Masks all but the last [visible] digits: '08012345678' → '•••••••5678'
  String maskPhone({int visible = 4}) {
    final d = replaceAll(RegExp(r'\D'), '');
    if (d.length <= visible) return d;
    return '${'•' * (d.length - visible)}${d.substring(d.length - visible)}';
  }

  /// Masks a card number: '4111111111111111' → '•••• •••• •••• 1111'
  String get maskedCard {
    final d = replaceAll(RegExp(r'\D'), '');
    if (d.length < 4) return d;
    return '•••• •••• •••• ${d.substring(d.length - 4)}';
  }

  // ── Validation ───────────────────────────────────────────────────────────

  bool get isValidEmail =>
      RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(trim());

  bool get isValidPhone =>
      replaceAll(RegExp(r'\D'), '').length >= 10;

  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Strips everything except digits.
  String get digitsOnly => replaceAll(RegExp(r'\D'), '');

  /// Returns `null` if the string is empty, otherwise returns itself.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// Removes leading/trailing whitespace and collapses internal spaces.
  String get normalized => trim().replaceAll(RegExp(r'\s+'), ' ');
}

extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  String get orEmpty => this ?? '';
}
