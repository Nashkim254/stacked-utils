import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

import 'buttons_screen.dart';
import 'colors_screen.dart';
import 'forms_screen.dart';
import 'typography_screen.dart';
import 'widgets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _sections = [
    _Section('Buttons',    Icons.smart_button_outlined,   Colors.indigo,  ButtonsScreen()),
    _Section('Forms',      Icons.edit_note_outlined,       Colors.teal,    FormsScreen()),
    _Section('Widgets',    Icons.widgets_outlined,         Colors.orange,  WidgetsScreen()),
    _Section('Typography', Icons.text_fields_rounded,      Colors.purple,  TypographyScreen()),
    _Section('Colors',     Icons.palette_outlined,         Colors.pink,    ColorsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('app_kit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore components', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.xs),
            Text(
              'Tap a section to see all utilities and widgets.',
              style: context.textTheme.bodyMedium?.copyWith(color: AppColors.grey400),
            ),
            const Gap(AppSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.2,
              children: _sections.map((s) => _SectionCard(s)).toList(),
            ),
            const Gap(AppSpacing.xl),
            _ExtensionsDemo(),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;
  const _SectionCard(this.section);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(section.screen),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: section.color.withOpacity(0.12),
              borderRadius: AppRadius.mdBR,
            ),
            child: Icon(section.icon, color: section.color, size: 24),
          ),
          const Gap(AppSpacing.sm),
          Text(section.label, style: context.textTheme.labelMedium),
        ],
      ),
    );
  }
}

/// Live demo of String / DateTime / Num extensions.
class _ExtensionsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Extensions', style: context.textTheme.headlineSmall),
        const Gap(AppSpacing.md),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('StringX', style: AppTextStyles.label.semiBold),
              const AppDivider(),
              _row('"hello world".titleCase', 'hello world'.titleCase),
              _row('"John Doe".initials', 'John Doe'.initials),
              _row('"0801234".maskPhone()', '0801234'.maskPhone()),
              _row('"Long text…".truncate(8)', 'Long text example'.truncate(8)),
              _row('"abc@x.com".isValidEmail', 'abc@x.com'.isValidEmail.toString()),
            ],
          ),
        ),

        const Gap(AppSpacing.md),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DateTimeX', style: AppTextStyles.label.semiBold),
              const AppDivider(),
              _row('now.toReadableDate', now.toReadableDate),
              _row('now.toTimeString', now.toTimeString),
              _row('now.timeAgo', now.timeAgo),
              _row('now.isToday', now.isToday.toString()),
              _row('now.subtract(2h).timeAgo',
                  now.subtract(const Duration(hours: 2)).timeAgo),
            ],
          ),
        ),

        const Gap(AppSpacing.md),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NumX', style: AppTextStyles.label.semiBold),
              const AppDivider(),
              _row('1200.50.toCurrency("₦")', 1200.50.toCurrency(symbol: '₦')),
              _row('3400000.compact', 3400000.compact),
              _row('0.756.toPercent()', 0.756.toPercent()),
              _row('1048576.toFileSize', 1048576.toFileSize),
              _row('5.padded()', 5.padded()),
            ],
          ),
        ),

        const Gap(AppSpacing.xl),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
        ),
        Text(value,
            style: AppTextStyles.bodySm
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _Section {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;
  const _Section(this.label, this.icon, this.color, this.screen);
}
