import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

import '../services/theme_service.dart';

class WidgetsScreen extends StatefulWidget {
  const WidgetsScreen({super.key});

  @override
  State<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends State<WidgetsScreen> {
  bool _showCard  = true;
  bool _isBusy    = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widgets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── AppCard ───────────────────────────────────────────────────
            _heading(context, 'AppCard'),
            AppCard(
              onTap: () => context.showSnackbar('Card tapped!'),
              child: Row(children: [
                const Icon(Icons.star_rounded, color: AppColors.warning),
                const Gap.h(AppSpacing.sm),
                Text('Tappable card', style: context.textTheme.bodyMedium),
              ]),
            ),
            const Gap(AppSpacing.sm),
            AppCard(
              showBorder: false,
              elevation: 3,
              child: Text('Elevated, no border', style: context.textTheme.bodyMedium),
            ),

            // ── AppListTile ───────────────────────────────────────────────
            _heading(context, 'AppListTile'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                AppListTile(
                  title: 'Profile',
                  subtitle: 'Manage your account',
                  leading: AppAvatar(name: 'John Doe', size: 40),
                  showChevron: true,
                  showDivider: true,
                  onTap: () {},
                ),
                AppListTile(
                  title: 'Notifications',
                  leading: const Icon(Icons.notifications_outlined),
                  trailing: AppBadge(label: '3', variant: BadgeVariant.error),
                  showChevron: true,
                  showDivider: true,
                  onTap: () {},
                ),
                AppListTile(
                  title: 'Dark Mode',
                  leading: const Icon(Icons.dark_mode_outlined),
                  trailing: Switch(
                    value: context.isDark,
                    onChanged: (_) => locate<ThemeService>().toggleTheme(),
                  ),
                  onTap: () => locate<ThemeService>().toggleTheme(),
                ),
              ]),
            ),

            // ── Badges ────────────────────────────────────────────────────
            _heading(context, 'AppBadge'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: const [
                AppBadge(label: 'Primary',  variant: BadgeVariant.primary),
                AppBadge(label: 'Success',  variant: BadgeVariant.success),
                AppBadge(label: 'Warning',  variant: BadgeVariant.warning),
                AppBadge(label: 'Error',    variant: BadgeVariant.error),
                AppBadge(label: 'Info',     variant: BadgeVariant.info),
                AppBadge(label: 'Neutral',  variant: BadgeVariant.neutral),
              ],
            ),

            // ── StatusChip ────────────────────────────────────────────────
            _heading(context, 'StatusChip'),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                const StatusChip.active(),
                const StatusChip.pending(),
                const StatusChip.inactive(),
                const StatusChip.failed(),
                const StatusChip.verified(),
                StatusChip(label: 'Custom', color: context.colors.secondary),
              ],
            ),

            // ── AppAvatar ─────────────────────────────────────────────────
            _heading(context, 'AppAvatar'),
            Row(
              children: [
                AppAvatar(name: 'John Doe', size: 48),
                const Gap.h(AppSpacing.sm),
                AppAvatar(name: 'Alice Smith', size: 40),
                const Gap.h(AppSpacing.sm),
                AppAvatar(name: 'Bob', size: 32),
                const Gap.h(AppSpacing.sm),
                // With online badge
                AppAvatar(
                  name: 'Online User',
                  size: 48,
                  badge: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            // ── AppNetworkImage ───────────────────────────────────────────
            _heading(context, 'AppNetworkImage'),
            Row(children: [
              AppNetworkImage(
                url: 'https://picsum.photos/seed/kit1/200/200',
                width: 100, height: 100,
                radius: AppRadius.card,
              ),
              const Gap.h(AppSpacing.sm),
              AppNetworkImage(
                url: 'https://picsum.photos/seed/kit2/200/200',
                width: 100, height: 100,
                radius: AppRadius.full,
              ),
              const Gap.h(AppSpacing.sm),
              // Broken URL → error fallback
              AppNetworkImage(
                url: 'https://broken-url/image.png',
                width: 100, height: 100,
                radius: AppRadius.card,
              ),
            ]),

            // ── Shimmer ───────────────────────────────────────────────────
            _heading(context, 'ShimmerBox'),
            ShowIf(
              condition: _isLoading,
              child: Column(children: [
                ShimmerBox(width: double.infinity, height: 56),
                const Gap(AppSpacing.sm),
                Row(children: [
                  ShimmerBox(width: 48, height: 48, radius: AppRadius.full),
                  const Gap.h(AppSpacing.sm),
                  Expanded(child: Column(children: [
                    ShimmerBox(width: double.infinity, height: 14),
                    const Gap(AppSpacing.xs),
                    ShimmerBox(width: double.infinity, height: 14),
                  ])),
                ]),
              ]),
              fallback: const Text('Content loaded! (shimmer shown for 2s on entry)'),
            ),

            // ── ShowIf ────────────────────────────────────────────────────
            _heading(context, 'ShowIf'),
            Row(children: [
              Switch(
                value: _showCard,
                onChanged: (v) => setState(() => _showCard = v),
              ),
              const Gap.h(AppSpacing.sm),
              const Text('Toggle card'),
            ]),
            ShowIf(
              condition: _showCard,
              child: AppCard(
                child: Text('Visible!', style: context.textTheme.bodyMedium),
              ),
              fallback: Text(
                'Hidden — toggle the switch',
                style: AppTextStyles.body.copyWith(color: AppColors.grey400),
              ),
            ),

            // ── BusyOverlay ───────────────────────────────────────────────
            _heading(context, 'BusyOverlay'),
            BusyOverlay(
              busy: _isBusy,
              child: AppCard(
                child: Column(children: [
                  Text('Wrapped content', style: context.textTheme.bodyMedium),
                  const Gap(AppSpacing.sm),
                  AppButton(
                    label: _isBusy ? 'Loading…' : 'Trigger overlay (2s)',
                    size: ButtonSize.sm,
                    onTap: _isBusy ? null : () async {
                      setState(() => _isBusy = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _isBusy = false);
                    },
                  ),
                ]),
              ),
            ),

            // ── AppDivider ────────────────────────────────────────────────
            _heading(context, 'AppDivider'),
            const AppDivider(),
            const AppDivider(label: 'or continue with'),
            const AppDivider(label: 'Section', labelLeft: true),

            // ── EmptyState ────────────────────────────────────────────────
            _heading(context, 'EmptyState'),
            AppCard(
              child: EmptyState(
                icon: Icons.inbox_outlined,
                message: 'No items yet',
                subMessage: 'Items you add will appear here.',
                onRetry: () {},
                retryLabel: 'Add item',
              ),
            ),

            // ── ErrorView ─────────────────────────────────────────────────
            _heading(context, 'ErrorView'),
            AppCard(
              child: ErrorView(
                message: 'Failed to load data. Check your connection.',
                onRetry: () {},
              ),
            ),

            // ── Gap ───────────────────────────────────────────────────────
            _heading(context, 'Gap'),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gap(xs) = 4'),
                  Gap(AppSpacing.xs),
                  const Divider(),
                  const Text('Gap(sm) = 8'),
                  Gap(AppSpacing.sm),
                  const Divider(),
                  const Text('Gap(md) = 16'),
                  Gap(AppSpacing.md),
                  const Divider(),
                  const Text('Gap(lg) = 24'),
                  Gap(AppSpacing.lg),
                  const Divider(),
                  Row(children: [
                    const Text('Gap.h(sm)'),
                    Gap.h(AppSpacing.sm),
                    Container(width: 1, height: 20, color: AppColors.grey300),
                    Gap.h(AppSpacing.sm),
                    const Text('Gap.h(lg)'),
                    Gap.h(AppSpacing.lg),
                    Container(width: 1, height: 20, color: AppColors.grey300),
                  ]),
                ],
              ),
            ),

            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
    child: Text(title, style: context.textTheme.headlineSmall),
  );
}
