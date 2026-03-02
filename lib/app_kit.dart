/// app_kit — A repository of production-ready utilities, widgets, theming,
/// and Stacked base classes for Flutter teams.
library app_kit;

// ── Core ────────────────────────────────────────────────────────────────────
export 'core/utils/result.dart';
export 'core/utils/validators.dart';
export 'core/extensions/viewmodel_extensions.dart';
export 'core/extensions/locator_helper.dart';
export 'core/mixins/common_viewmodel_mixin.dart';
export 'core/services/base_api_service.dart';
export 'core/services/storage_service.dart';

// ── UI — Constants ───────────────────────────────────────────────────────────
export 'ui/constants/app_colors.dart';
export 'ui/constants/app_spacing.dart';
export 'ui/constants/app_radius.dart';
export 'ui/constants/app_text_styles.dart';

// ── UI — Theme ───────────────────────────────────────────────────────────────
export 'ui/theme/app_theme.dart';

// ── UI — Utils / Extensions ──────────────────────────────────────────────────
export 'ui/utils/context_extensions.dart';
export 'ui/utils/widget_extensions.dart';
export 'ui/utils/text_style_extensions.dart';
export 'ui/utils/responsive.dart';

// ── UI — Shared Widgets ──────────────────────────────────────────────────────
export 'ui/shared/gap.dart';
export 'ui/shared/show_if.dart';
export 'ui/shared/busy_overlay.dart';
export 'ui/shared/empty_state.dart';
export 'ui/shared/error_view.dart';
export 'ui/shared/shimmer_box.dart';
export 'ui/shared/app_text_field.dart';
export 'ui/shared/app_button.dart';
export 'ui/shared/app_icon_button.dart';
export 'ui/shared/app_card.dart';
export 'ui/shared/app_badge.dart';
export 'ui/shared/app_avatar.dart';
export 'ui/shared/app_divider.dart';
export 'ui/shared/app_bottom_sheet.dart';
export 'ui/shared/status_chip.dart';
