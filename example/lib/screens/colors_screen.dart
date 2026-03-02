import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Colors')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _heading(context, 'Neutrals'),
            _palette([
              _Swatch('grey50',  AppColors.grey50),
              _Swatch('grey100', AppColors.grey100),
              _Swatch('grey200', AppColors.grey200),
              _Swatch('grey300', AppColors.grey300),
              _Swatch('grey400', AppColors.grey400),
              _Swatch('grey500', AppColors.grey500),
              _Swatch('grey600', AppColors.grey600),
              _Swatch('grey700', AppColors.grey700),
              _Swatch('grey800', AppColors.grey800),
              _Swatch('grey900', AppColors.grey900),
            ]),

            _heading(context, 'Semantic'),
            _palette([
              _Swatch('success',      AppColors.success),
              _Swatch('successLight', AppColors.successLight),
              _Swatch('warning',      AppColors.warning),
              _Swatch('warningLight', AppColors.warningLight),
              _Swatch('error',        AppColors.error),
              _Swatch('errorLight',   AppColors.errorLight),
              _Swatch('info',         AppColors.info),
              _Swatch('infoLight',    AppColors.infoLight),
            ]),

            _heading(context, 'Surfaces (Light)'),
            _palette([
              _Swatch('surface',    AppColors.surface),
              _Swatch('background', AppColors.background),
              _Swatch('border',     AppColors.border),
            ]),

            _heading(context, 'Surfaces (Dark)'),
            _palette([
              _Swatch('surfaceDark',    AppColors.surfaceDark),
              _Swatch('backgroundDark', AppColors.backgroundDark),
              _Swatch('borderDark',     AppColors.borderDark),
            ]),

            _heading(context, 'ColorScheme (from theme)'),
            AppCard(
              child: Column(
                children: [
                  _schemeRow(context, 'primary',          context.colors.primary),
                  _schemeRow(context, 'primaryContainer', context.colors.primaryContainer),
                  _schemeRow(context, 'secondary',        context.colors.secondary),
                  _schemeRow(context, 'tertiary',         context.colors.tertiary),
                  _schemeRow(context, 'surface',          context.colors.surface),
                  _schemeRow(context, 'error',            context.colors.error),
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

  Widget _palette(List<_Swatch> swatches) {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 0.75,
      children: swatches.map(_SwatchTile.new).toList(),
    );
  }

  Widget _schemeRow(BuildContext context, String name, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.smBR,
            border: Border.all(color: AppColors.grey200),
          ),
        ),
        const Gap.h(AppSpacing.sm),
        Expanded(
          child: Text(name, style: AppTextStyles.bodySm),
        ),
        Text(
          '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}',
          style: AppTextStyles.caption.copyWith(color: AppColors.grey500),
        ),
      ],
    ),
  );
}

class _Swatch {
  final String name;
  final Color color;
  const _Swatch(this.name, this.color);
}

class _SwatchTile extends StatelessWidget {
  final _Swatch swatch;
  const _SwatchTile(this.swatch, {super.key});

  @override
  Widget build(BuildContext context) {
    final hex = '#${swatch.color.value.toRadixString(16).toUpperCase().substring(2)}';
    final isLight = swatch.color.computeLuminance() > 0.5;
    final labelColor = isLight ? AppColors.grey700 : AppColors.grey100;

    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: swatch.color,
              borderRadius: AppRadius.smBR,
              border: Border.all(color: AppColors.grey200),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              hex,
              style: TextStyle(
                fontSize: 8,
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Gap(4),
        Text(
          swatch.name,
          style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
