import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

/// A color-coded pill chip for statuses such as Active, Pending, Inactive, etc.
/// Pass any [color] to create custom variants beyond the preset ones.
///
/// ```dart
/// StatusChip.active()
/// StatusChip.pending()
/// StatusChip.inactive()
/// StatusChip(label: 'Verified', color: AppColors.info)
/// ```
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool dot;

  const StatusChip({
    required this.label,
    required this.color,
    this.dot = true,
    super.key,
  });

  // ── Named constructors ───────────────────────────────────────────────────

  const StatusChip.active({super.key})
      : label = 'Active',
        color = AppColors.success,
        dot = true;

  const StatusChip.inactive({super.key})
      : label = 'Inactive',
        color = AppColors.grey400,
        dot = true;

  const StatusChip.pending({super.key})
      : label = 'Pending',
        color = AppColors.warning,
        dot = true;

  const StatusChip.failed({super.key})
      : label = 'Failed',
        color = AppColors.error,
        dot = true;

  const StatusChip.verified({super.key})
      : label = 'Verified',
        color = AppColors.info,
        dot = true;

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(0.12);
    final fg = color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullBR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
