import 'package:flutter/material.dart';

/// A gap widget that replaces [SizedBox] for vertical/horizontal spacing.
///
/// ```dart
/// Column(children: [
///   Text('Hello'),
///   Gap(AppSpacing.md),
///   Text('World'),
/// ])
/// ```
class Gap extends StatelessWidget {
  final double size;
  final bool horizontal;

  const Gap(this.size, {this.horizontal = false, super.key});

  /// Shorthand for a horizontal gap.
  const Gap.h(this.size, {super.key}) : horizontal = true;

  /// Shorthand for a vertical gap.
  const Gap.v(this.size, {super.key}) : horizontal = false;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: horizontal ? size : null,
        height: horizontal ? null : size,
      );
}
