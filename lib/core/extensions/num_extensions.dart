import 'package:intl/intl.dart';

extension NumX on num {
  // ── Currency ─────────────────────────────────────────────────────────────

  /// Formats as currency: `1200.5.toCurrency('₦')` → `'₦1,200.50'`
  String toCurrency({
    String symbol = '',
    int decimalPlaces = 2,
    String locale = 'en_US',
  }) {
    final format = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalPlaces,
    );
    return format.format(this);
  }

  /// Shorthand using a locale pattern: `1200.toNaira` → `'₦1,200.00'`
  String toSymbolCurrency(String symbol) => toCurrency(symbol: symbol);

  // ── Compact notation ─────────────────────────────────────────────────────

  /// `1200` → `'1.2k'`, `3_400_000` → `'3.4M'`, `2_100_000_000` → `'2.1B'`
  String get compact {
    final absVal = abs();
    final sign = this < 0 ? '-' : '';
    if (absVal >= 1e9) return '$sign${(absVal / 1e9).toStringAsFixed(1)}B';
    if (absVal >= 1e6) return '$sign${(absVal / 1e6).toStringAsFixed(1)}M';
    if (absVal >= 1e3) return '$sign${(absVal / 1e3).toStringAsFixed(1)}k';
    return toString();
  }

  // ── Percentage ───────────────────────────────────────────────────────────

  /// `0.756.toPercent()` → `'75.6%'`
  String toPercent({int decimalPlaces = 1, bool multiply = true}) {
    final value = multiply ? this * 100 : this;
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  // ── Duration shorthands ──────────────────────────────────────────────────

  Duration get seconds      => Duration(seconds: toInt());
  Duration get milliseconds => Duration(milliseconds: toInt());
  Duration get minutes      => Duration(minutes: toInt());

  // ── Checks ───────────────────────────────────────────────────────────────

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero     => this == 0;

  // ── Clamped helpers ──────────────────────────────────────────────────────

  num clampMin(num min) => this < min ? min : this;
  num clampMax(num max) => this > max ? max : this;
}

extension IntX on int {
  /// Pads to a minimum [width] with leading zeros: `5.padded(2)` → `'05'`
  String padded([int width = 2]) => toString().padLeft(width, '0');

  /// Formats bytes into a readable size: `1024.toFileSize()` → `'1.0 KB'`
  String get toFileSize {
    if (this < 1024) return '${this} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
