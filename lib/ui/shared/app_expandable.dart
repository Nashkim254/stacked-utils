import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A card-like expandable/collapsible container with animated height transition.
///
/// Uses [ValueNotifier] + [ValueListenableBuilder] for local state — no setState.
/// The header row is always visible; the [child] slides in/out via [SizeTransition].
///
/// ```dart
/// AppExpandable(
///   title: 'Shipping details',
///   child: ShippingForm(),
///   initiallyExpanded: true,
///   onExpansionChanged: (open) => viewModel.trackPanel(open),
/// )
///
/// // String-convenience constructor:
/// AppExpandable.fromString(
///   titleText: 'FAQ item',
///   child: Text('Answer goes here…'),
/// )
/// ```
class AppExpandable extends StatefulWidget {
  /// Widget displayed in the header row (left side).
  final Widget title;

  /// Body that is revealed when expanded.
  final Widget child;

  /// Whether the panel starts open.
  final bool initiallyExpanded;

  /// Optional custom widget that replaces the default animated chevron.
  final Widget? trailing;

  /// Called whenever the expanded state flips.
  final ValueChanged<bool>? onExpansionChanged;

  const AppExpandable({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.trailing,
    this.onExpansionChanged,
    super.key,
  });

  /// Convenience constructor that accepts a plain [String] as the title.
  factory AppExpandable.fromString({
    required String titleText,
    required Widget child,
    bool initiallyExpanded = false,
    Widget? trailing,
    ValueChanged<bool>? onExpansionChanged,
    Key? key,
  }) {
    return AppExpandable(
      key: key,
      title: Text(titleText, style: AppTextStyles.label),
      child: child,
      initiallyExpanded: initiallyExpanded,
      trailing: trailing,
      onExpansionChanged: onExpansionChanged,
    );
  }

  @override
  State<AppExpandable> createState() => _AppExpandableState();
}

class _AppExpandableState extends State<AppExpandable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final ValueNotifier<bool> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = ValueNotifier<bool>(widget.initiallyExpanded);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.initiallyExpanded ? 1.0 : 0.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _expanded.dispose();
    super.dispose();
  }

  void _toggle() {
    final next = !_expanded.value;
    _expanded.value = next;
    if (next) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onExpansionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final borderColor =
        isLight ? AppColors.border : AppColors.borderDark;
    final borderRadius = BorderRadius.circular(AppRadius.card);

    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.surface : AppColors.surfaceDark,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────
            InkWell(
              borderRadius: borderRadius,
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(child: widget.title),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTrailing(),
                  ],
                ),
              ),
            ),
            // ── Body ────────────────────────────────────────────────────
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: borderColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (widget.trailing != null) return widget.trailing!;

    return ValueListenableBuilder<bool>(
      valueListenable: _expanded,
      builder: (_, expanded, __) => AnimatedRotation(
        turns: expanded ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
