import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

class ButtonsScreen extends StatefulWidget {
  const ButtonsScreen({super.key});

  @override
  State<ButtonsScreen> createState() => _ButtonsScreenState();
}

class _ButtonsScreenState extends State<ButtonsScreen> {
  bool _busy = false;

  Future<void> _simulateLoad() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _section(context, 'Variants', [
              AppButton(label: 'Primary',   onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Secondary', variant: ButtonVariant.secondary, onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Outline',   variant: ButtonVariant.outline,   onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Ghost',     variant: ButtonVariant.ghost,     onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Danger',    variant: ButtonVariant.danger,    onTap: () {}),
            ]),

            _section(context, 'Sizes', [
              AppButton(label: 'Small',  size: ButtonSize.sm, onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Medium', size: ButtonSize.md, onTap: () {}),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Large',  size: ButtonSize.lg, onTap: () {}),
            ]),

            _section(context, 'States', [
              AppButton(label: 'Busy',     onTap: _simulateLoad, busy: _busy),
              const Gap(AppSpacing.sm),
              AppButton(label: 'Disabled', onTap: () {}, disabled: true),
            ]),

            _section(context, 'With Icons', [
              AppButton(
                label: 'Leading icon',
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onTap: () {},
              ),
              const Gap(AppSpacing.sm),
              AppButton(
                label: 'Trailing icon',
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                iconRight: true,
                onTap: () {},
              ),
              const Gap(AppSpacing.sm),
              AppButton(
                label: 'Delete',
                variant: ButtonVariant.danger,
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onTap: () {},
              ),
            ]),

            _section(context, 'Fixed Width', [
              Row(
                children: [
                  AppButton(label: 'Cancel', variant: ButtonVariant.outline, onTap: () {}, width: 120),
                  const Gap.h(AppSpacing.sm),
                  AppButton(label: 'Confirm', onTap: () {}, width: 120),
                ],
              ),
            ]),

            _section(context, 'Icon Buttons', [
              Row(
                children: [
                  AppIconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onTap: () {},
                    tooltip: 'Notifications',
                  ),
                  const Gap.h(AppSpacing.sm),
                  AppIconButton(
                    icon: const Icon(Icons.add),
                    onTap: () {},
                    outlined: true,
                    tooltip: 'Add',
                  ),
                  const Gap.h(AppSpacing.sm),
                  AppIconButton(
                    icon: const Icon(Icons.share_outlined),
                    onTap: () {},
                    backgroundColor: context.colors.primaryContainer,
                    foregroundColor: context.colors.primary,
                    tooltip: 'Share',
                  ),
                ],
              ),
            ]),

          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.textTheme.headlineSmall),
        const Gap(AppSpacing.md),
        ...children,
        const Gap(AppSpacing.xl),
      ],
    );
  }
}
