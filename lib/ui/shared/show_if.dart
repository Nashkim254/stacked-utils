import 'package:flutter/material.dart';

/// Conditionally renders [child] — replaces noisy ternary expressions.
///
/// ```dart
/// ShowIf(
///   condition: viewModel.isLoggedIn,
///   child: ProfileBadge(),
///   fallback: LoginButton(),
/// )
/// ```
class ShowIf extends StatelessWidget {
  final bool condition;
  final Widget child;
  final Widget? fallback;

  const ShowIf({
    required this.condition,
    required this.child,
    this.fallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) =>
      condition ? child : (fallback ?? const SizedBox.shrink());
}
