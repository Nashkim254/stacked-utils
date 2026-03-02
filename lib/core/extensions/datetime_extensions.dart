import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  // ── Relative time ────────────────────────────────────────────────────────

  /// Returns a human-readable relative string: 'just now', '5 minutes ago',
  /// 'yesterday', '3 Jan 2024', etc.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)     return 'yesterday';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365)    return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  // ── Formatting ───────────────────────────────────────────────────────────

  /// Formats using an [intl] pattern, e.g. `'dd MMM yyyy'`, `'hh:mm a'`.
  String format(String pattern) => DateFormat(pattern).format(this);

  /// '14 Jan 2024'
  String get toReadableDate => format('dd MMM yyyy');

  /// 'Jan 14, 2024'
  String get toReadableDateAlt => format('MMM dd, yyyy');

  /// '14 Jan 2024, 09:30 AM'
  String get toReadableDateTime => format('dd MMM yyyy, hh:mm a');

  /// '09:30 AM'
  String get toTimeString => format('hh:mm a');

  /// '14:30'
  String get to24HourTime => format('HH:mm');

  /// ISO-8601 date only: '2024-01-14'
  String get toIso8601Date => format('yyyy-MM-dd');

  // ── Checks ───────────────────────────────────────────────────────────────

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  bool get isThisYear => year == DateTime.now().year;

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  // ── Boundaries ───────────────────────────────────────────────────────────

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  // ── Arithmetic ───────────────────────────────────────────────────────────

  DateTime addDays(int days) => add(Duration(days: days));
  DateTime subtractDays(int days) => subtract(Duration(days: days));
}

extension NullableDateTimeX on DateTime? {
  /// Returns [timeAgo] or [fallback] if null.
  String timeAgoOr(String fallback) => this?.timeAgo ?? fallback;

  /// Returns formatted date or [fallback] if null.
  String formatOr(String pattern, {String fallback = '—'}) =>
      this == null ? fallback : DateFormat(pattern).format(this!);
}
