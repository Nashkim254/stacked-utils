import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  static const _styles = [
    ('displayLg',  'Display Large',  36.0, FontWeight.w800),
    ('displaySm',  'Display Small',  28.0, FontWeight.w700),
    ('h1',         'Heading 1',      24.0, FontWeight.w700),
    ('h2',         'Heading 2',      20.0, FontWeight.w600),
    ('h3',         'Heading 3',      18.0, FontWeight.w600),
    ('bodyLg',     'Body Large',     16.0, FontWeight.w400),
    ('body',       'Body',           14.0, FontWeight.w400),
    ('bodySm',     'Body Small',     12.0, FontWeight.w400),
    ('label',      'Label',          13.0, FontWeight.w500),
    ('caption',    'Caption',        11.0, FontWeight.w400),
    ('overline',   'Overline',       10.0, FontWeight.w600),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typography')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text('AppTextStyles', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),

            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: _styles.asMap().entries.map((e) {
                  final (name, label, size, weight) = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: size,
                                  fontWeight: weight,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${size.toInt()}px',
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  name,
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (e.key < _styles.length - 1)
                        const Divider(height: 1, indent: AppSpacing.md),
                    ],
                  );
                }).toList(),
              ),
            ),

            const Gap(AppSpacing.xl),
            Text('TextStyleX Extensions', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('.bold',        style: AppTextStyles.body.bold),
                  const Gap(AppSpacing.xs),
                  Text('.semiBold',    style: AppTextStyles.body.semiBold),
                  const Gap(AppSpacing.xs),
                  Text('.italic',      style: AppTextStyles.body.italic),
                  const Gap(AppSpacing.xs),
                  Text('.underline',   style: AppTextStyles.body.underline),
                  const Gap(AppSpacing.xs),
                  Text('.lineThrough', style: AppTextStyles.body.lineThrough),
                  const Gap(AppSpacing.xs),
                  Text('.colored(error)',
                      style: AppTextStyles.body.colored(AppColors.error)),
                  const Gap(AppSpacing.xs),
                  Text('.sized(20)',   style: AppTextStyles.body.sized(20)),
                  const Gap(AppSpacing.xs),
                  Text('.spaced(3)',   style: AppTextStyles.body.spaced(3)),
                  const Gap(AppSpacing.xs),
                  Text(
                    'Chained: .bold.italic.colored(primary)',
                    style: AppTextStyles.body
                        .bold
                        .italic
                        .colored(AppColors.info),
                  ),
                ],
              ),
            ),

            const Gap(AppSpacing.xl),
            Text('ContextX Extensions', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ext(context, 'context.screenWidth',    '${context.screenWidth.toInt()}px'),
                  _ext(context, 'context.screenHeight',   '${context.screenHeight.toInt()}px'),
                  _ext(context, 'context.statusBarHeight','${context.statusBarHeight.toInt()}px'),
                  _ext(context, 'context.isDark',         context.isDark.toString()),
                  _ext(context, 'context.primaryColor',   '#${context.primaryColor.value.toRadixString(16).toUpperCase()}'),
                ],
              ),
            ),

            const Gap(AppSpacing.xl),
            Text('WidgetX Extensions', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('padH(16) + center()').padH(16).center(),
                  const Gap(AppSpacing.sm),
                  const Text('visible(true)').visible(true),
                  const Gap(AppSpacing.sm),
                  const Text('opacity(0.4)').opacity(0.4),
                  const Gap(AppSpacing.sm),
                  const Text('clipRounded(8)')
                      .padAll(8)
                      .decorated(BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: AppRadius.smBR,
                      )),
                ],
              ),
            ),

            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _ext(BuildContext context, String name, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(name,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
        ),
        Text(value, style: AppTextStyles.bodySm.semiBold),
      ],
    ),
  );
}
