import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A themed group of selectable chips supporting single- or multi-select.
///
/// Uses [ValueNotifier] + [ValueListenableBuilder] for local selection state —
/// no setState.  Selected chips pick up `colorScheme.primary` /
/// `colorScheme.primaryContainer` from the ambient theme so they are always
/// on-brand without hard-coding colors.
///
/// ```dart
/// AppChipGroup<String>(
///   items: const ['Flutter', 'Dart', 'Firebase'],
///   displayLabel: (s) => s,
///   selected: viewModel.selectedTags,
///   onChanged: viewModel.setTags,
/// )
///
/// // Single-select
/// AppChipGroup<int>(
///   items: const [1, 2, 3, 4, 5],
///   displayLabel: (n) => '$n star${n == 1 ? '' : 's'}',
///   selected: [viewModel.rating],
///   singleSelect: true,
///   onChanged: (list) => viewModel.setRating(list.firstOrNull),
/// )
/// ```
class AppChipGroup<T> extends StatefulWidget {
  /// All available items.
  final List<T> items;

  /// Converts an item into a display string.
  final String Function(T) displayLabel;

  /// Items that start selected (must be a subset of [items]).
  final List<T> selected;

  /// Called with the updated selection whenever the user toggles a chip.
  final ValueChanged<List<T>> onChanged;

  /// When true only one chip may be selected at a time; tapping an already-
  /// selected chip in single-select mode deselects it.
  final bool singleSelect;

  /// When false all chips are rendered disabled and taps are ignored.
  final bool enabled;

  const AppChipGroup({
    required this.items,
    required this.displayLabel,
    required this.selected,
    required this.onChanged,
    this.singleSelect = false,
    this.enabled = true,
    super.key,
  });

  @override
  State<AppChipGroup<T>> createState() => _AppChipGroupState<T>();
}

class _AppChipGroupState<T> extends State<AppChipGroup<T>> {
  late final ValueNotifier<List<T>> _selected;

  @override
  void initState() {
    super.initState();
    _selected = ValueNotifier<List<T>>(List<T>.from(widget.selected));
  }

  @override
  void didUpdateWidget(AppChipGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep notifier in sync when the parent pushes a new selection.
    if (oldWidget.selected != widget.selected) {
      _selected.value = List<T>.from(widget.selected);
    }
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _onTap(T item) {
    if (!widget.enabled) return;

    final current = List<T>.from(_selected.value);

    if (widget.singleSelect) {
      if (current.contains(item)) {
        current.remove(item);
      } else {
        current
          ..clear()
          ..add(item);
      }
    } else {
      if (current.contains(item)) {
        current.remove(item);
      } else {
        current.add(item);
      }
    }

    _selected.value = current;
    widget.onChanged(List<T>.unmodifiable(current));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<T>>(
      valueListenable: _selected,
      builder: (context, selected, _) {
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: widget.items.map((item) {
            final isSelected = selected.contains(item);
            return _AppChip(
              label: widget.displayLabel(item),
              selected: isSelected,
              enabled: widget.enabled,
              onTap: () => _onTap(item),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Internal chip widget ──────────────────────────────────────────────────────

class _AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _AppChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final Color bg;
    final Color fg;
    final Color border;

    if (!enabled) {
      bg = isLight ? AppColors.grey100 : AppColors.grey700;
      fg = isLight ? AppColors.grey400 : AppColors.grey500;
      border = isLight ? AppColors.grey200 : AppColors.borderDark;
    } else if (selected) {
      bg = cs.primaryContainer;
      fg = cs.onPrimaryContainer;
      border = cs.primary;
    } else {
      bg = isLight ? AppColors.grey50 : AppColors.surfaceDark;
      fg = isLight ? AppColors.grey700 : AppColors.grey300;
      border = isLight ? AppColors.grey200 : AppColors.borderDark;
    }

    return Material(
      color: bg,
      borderRadius: AppRadius.fullBR,
      child: InkWell(
        borderRadius: AppRadius.fullBR,
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: border),
            borderRadius: AppRadius.fullBR,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 14, color: fg),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.label.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
