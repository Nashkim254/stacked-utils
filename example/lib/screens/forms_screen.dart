import 'package:app_kit/app_kit.dart';
import 'package:flutter/material.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _bioCtrl      = TextEditingController();
  final _searchCtrl   = TextEditingController();

  String? _selectedCountry;
  String? _selectedCity;
  List<String> _selectedSkills = [];
  String _otpValue = '';
  bool _submitting = false;
  String _searchQuery = '';

  static const _countries = ['Nigeria', 'Ghana', 'Kenya', 'South Africa', 'Egypt'];

  static const _skills = [
    'Flutter', 'Dart', 'Firebase', 'REST APIs', 'GraphQL',
    'Git', 'CI/CD', 'Unit Testing', 'State Management', 'UI/UX',
  ];

  static const _cities = [
    'Lagos', 'Abuja', 'Kano', 'Ibadan', 'Port Harcourt',
    'Accra', 'Kumasi', 'Tamale',
    'Nairobi', 'Mombasa', 'Kisumu',
    'Johannesburg', 'Cape Town', 'Durban', 'Pretoria',
    'Cairo', 'Alexandria', 'Giza',
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forms')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Search field ──────────────────────────────────────────────
            Text('AppSearchField', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            AppSearchField(
              controller: _searchCtrl,
              hint: 'Search anything…',
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              Text('Query: "$_searchQuery"',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
            ],

            const Gap(AppSpacing.xl),

            // ── Select search ─────────────────────────────────────────────
            Text('AppSelectSearch', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            AppSelectSearch<String>(
              label: 'City',
              hint: 'Type to search cities…',
              items: _cities,
              displayLabel: (c) => c,
              value: _selectedCity,
              onSelected: (c) => setState(() => _selectedCity = c),
            ),
            if (_selectedCity != null) ...[
              const Gap(AppSpacing.sm),
              Text('Selected: $_selectedCity',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
            ],

            const Gap(AppSpacing.xl),

            // ── OTP field ─────────────────────────────────────────────────
            Text('AppOtpField', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            AppOtpField(
              length: 6,
              onChanged: (v) => setState(() => _otpValue = v),
              onCompleted: (v) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('OTP entered: $v')),
              ),
            ),
            if (_otpValue.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              Text('Current: $_otpValue',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
            ],

            const Gap(AppSpacing.xl),

            // ── Multi select ──────────────────────────────────────────────
            Text('AppMultiSelect', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            AppMultiSelect<String>(
              label: 'Skills',
              hint: 'Select your skills',
              items: _skills,
              displayLabel: (s) => s,
              values: _selectedSkills,
              onChanged: (v) => setState(() => _selectedSkills = v),
              maxSelections: 5,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Select at least one skill' : null,
            ),
            if (_selectedSkills.isNotEmpty) ...[
              const Gap(AppSpacing.sm),
              Text('Selected: ${_selectedSkills.join(', ')}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.grey500)),
            ],

            const Gap(AppSpacing.xl),

            // ── Full form ─────────────────────────────────────────────────
            Text('Form with Validation', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Email address',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                    showClearButton: true,
                  ),
                  const Gap(AppSpacing.md),
                  AppTextField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    obscure: true,
                    validator: Validators.password,
                  ),
                  const Gap(AppSpacing.md),
                  AppTextField(
                    label: 'Phone number',
                    hint: '0801 234 5678',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    validator: Validators.phone,
                  ),
                  const Gap(AppSpacing.md),
                  AppDropdown<String>(
                    label: 'Country',
                    hint: 'Select your country',
                    value: _selectedCountry,
                    items: _countries
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCountry = v),
                    validator: (v) => v == null ? 'Please select a country' : null,
                  ),
                  const Gap(AppSpacing.md),
                  AppTextField(
                    label: 'Bio',
                    hint: 'Tell us about yourself…',
                    controller: _bioCtrl,
                    maxLines: 4,
                    maxLength: 300,
                    validator: (v) => Validators.maxLength(v, 300),
                  ),
                  const Gap(AppSpacing.lg),
                  AppButton(
                    label: 'Submit',
                    onTap: _submit,
                    busy: _submitting,
                  ),
                ],
              ),
            ),

            const Gap(AppSpacing.xl),

            // ── Individual field states ────────────────────────────────────
            Text('Field States', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            const AppTextField(
              label: 'Read-only field',
              initialValue: 'Cannot be edited',
              readOnly: true,
            ),
            const Gap(AppSpacing.md),
            const AppTextField(
              label: 'Disabled field',
              initialValue: 'Disabled',
              enabled: false,
            ),
            const Gap(AppSpacing.xl),

            // ── Validators chained ────────────────────────────────────────
            Text('Compose Validators', style: context.textTheme.headlineSmall),
            const Gap(AppSpacing.md),
            AppTextField(
              label: 'Username (4-20 chars, required)',
              validator: Validators.compose([
                Validators.required,
                (v) => Validators.minLength(v, 4),
                (v) => Validators.maxLength(v, 20),
              ]),
            ),
            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
