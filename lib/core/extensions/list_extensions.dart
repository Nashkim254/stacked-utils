/// Extensions on [List] for common collection operations.
extension ListX<T> on List<T> {
  // ── Grouping ──────────────────────────────────────────────────────────────

  /// Groups list items into a map keyed by [keyOf].
  ///
  /// ```dart
  /// ['a', 'bb', 'cc', 'ddd'].groupBy((s) => s.length);
  /// // {1: ['a'], 2: ['bb', 'cc'], 3: ['ddd']}
  /// ```
  Map<K, List<T>> groupBy<K>(K Function(T) keyOf) {
    final result = <K, List<T>>{};
    for (final item in this) {
      result.putIfAbsent(keyOf(item), () => <T>[]).add(item);
    }
    return result;
  }

  // ── Deduplication ─────────────────────────────────────────────────────────

  /// Returns a new list with duplicates removed by [keyOf], preserving the
  /// first occurrence of each key.
  ///
  /// ```dart
  /// [{'id': 1}, {'id': 2}, {'id': 1}].distinctBy((m) => m['id']);
  /// // [{'id': 1}, {'id': 2}]
  /// ```
  List<T> distinctBy<K>(K Function(T) keyOf) {
    final seen = <K>{};
    final result = <T>[];
    for (final item in this) {
      if (seen.add(keyOf(item))) result.add(item);
    }
    return result;
  }

  // ── Chunking ──────────────────────────────────────────────────────────────

  /// Splits the list into sub-lists of at most [size] elements.
  ///
  /// The last chunk may be smaller if the list length is not evenly divisible.
  ///
  /// ```dart
  /// [1, 2, 3, 4, 5].chunk(2); // [[1, 2], [3, 4], [5]]
  /// ```
  List<List<T>> chunk(int size) {
    assert(size > 0, 'chunk size must be greater than 0');
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size).clamp(0, length)));
    }
    return result;
  }

  // ── Safe search ───────────────────────────────────────────────────────────

  /// Returns the first element matching [test], or `null` if none match.
  ///
  /// Unlike [Iterable.firstWhere], this does not throw when nothing is found.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }

  /// Returns the last element matching [test], or `null` if none match.
  ///
  /// Unlike [Iterable.lastWhere], this does not throw when nothing is found.
  T? lastWhereOrNull(bool Function(T) test) {
    T? result;
    for (final item in this) {
      if (test(item)) result = item;
    }
    return result;
  }

  // ── Sorting ───────────────────────────────────────────────────────────────

  /// Returns a new sorted list using [compare], leaving the original unchanged.
  ///
  /// ```dart
  /// final sorted = [3, 1, 2].sorted((a, b) => a.compareTo(b)); // [1, 2, 3]
  /// ```
  List<T> sorted(Comparator<T> compare) => [...this]..sort(compare);

  /// Returns a new list sorted ascending by the [Comparable] key [keyOf].
  ///
  /// ```dart
  /// ['banana', 'apple', 'cherry'].sortedBy((s) => s); // ['apple', 'banana', 'cherry']
  /// ```
  List<T> sortedBy<K extends Comparable<Object>>(K Function(T) keyOf) =>
      sorted((a, b) => keyOf(a).compareTo(keyOf(b)));

  /// Returns a new list sorted descending by the [Comparable] key [keyOf].
  ///
  /// ```dart
  /// ['banana', 'apple', 'cherry'].sortedByDescending((s) => s); // ['cherry', 'banana', 'apple']
  /// ```
  List<T> sortedByDescending<K extends Comparable<Object>>(K Function(T) keyOf) =>
      sorted((a, b) => keyOf(b).compareTo(keyOf(a)));

  // ── Indexed iteration ─────────────────────────────────────────────────────

  /// Maps each element together with its index.
  ///
  /// ```dart
  /// ['a', 'b'].mapIndexed((i, v) => '$i:$v'); // ['0:a', '1:b']
  /// ```
  List<R> mapIndexed<R>(R Function(int index, T item) transform) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(transform(i, this[i]));
    }
    return result;
  }

  /// Calls [action] for each element together with its index.
  ///
  /// ```dart
  /// ['a', 'b'].forEachIndexed((i, v) => print('$i: $v'));
  /// ```
  void forEachIndexed(void Function(int index, T item) action) {
    for (var i = 0; i < length; i++) {
      action(i, this[i]);
    }
  }

  // ── Predicates ────────────────────────────────────────────────────────────

  /// Returns `true` if no element satisfies [test].
  ///
  /// The inverse of [Iterable.any].
  ///
  /// ```dart
  /// [1, 3, 5].none((n) => n.isEven); // true
  /// ```
  bool none(bool Function(T) test) => !any(test);

  /// Returns the number of elements that satisfy [test].
  ///
  /// ```dart
  /// [1, 2, 3, 4].count((n) => n.isEven); // 2
  /// ```
  int count(bool Function(T) test) {
    var tally = 0;
    for (final item in this) {
      if (test(item)) tally++;
    }
    return tally;
  }
}

/// Extensions on a [List] of [num] for common aggregate operations.
extension NumListX on List<num> {
  // ── Aggregates ────────────────────────────────────────────────────────────

  /// The sum of all values in the list.
  ///
  /// Returns `0` for an empty list.
  num get sum => fold<num>(0, (acc, n) => acc + n);

  /// The arithmetic mean of all values.
  ///
  /// Returns `0.0` for an empty list.
  double get average => isEmpty ? 0.0 : sum / length;

  /// The minimum value in the list.
  ///
  /// Throws a [StateError] if the list is empty.
  num get min {
    if (isEmpty) throw StateError('min called on an empty list');
    return fold<num>(first, (a, b) => a < b ? a : b);
  }

  /// The maximum value in the list.
  ///
  /// Throws a [StateError] if the list is empty.
  num get max {
    if (isEmpty) throw StateError('max called on an empty list');
    return fold<num>(first, (a, b) => a > b ? a : b);
  }
}
