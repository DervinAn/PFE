import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final ok = await LocalAppStorage.instance.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      context.go(AppRoutes.home);
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.invalidCredentials)));
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text);
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.forgotPasswordTitle),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.lg,
          AppSizes.sm,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.forgotPasswordSubtitle,
                  style: const TextStyle(fontFamily: 'Nunito'),
                ),
                const SizedBox(height: AppSizes.md),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailAddress,
                  ),
                  validator: (value) => value?.trim().isEmpty == true
                      ? context.l10n.enterYourEmail
                      : null,
                ),
                const SizedBox(height: AppSizes.sm),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.newPassword,
                  ),
                  validator: (value) => value == null || value.length < 8
                      ? context.l10n.use8PlusCharactersWithSymbols
                      : null,
                ),
                const SizedBox(height: AppSizes.sm),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.confirmPassword,
                  ),
                  validator: (value) => value != newPasswordController.text
                      ? context.l10n.passwordsDoNotMatch
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final valid = formKey.currentState?.validate() ?? false;
              if (!valid) return;
              final l10n = context.l10n;
              final messenger = ScaffoldMessenger.of(context);
              final updated = await LocalAppStorage.instance.updatePassword(
                email: emailController.text,
                newPassword: newPasswordController.text,
              );
              if (!updated) {
                if (!ctx.mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.emailNotFound)),
                );
                return;
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx, true);
            },
            child: Text(context.l10n.resetPassword),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.passwordUpdated)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSizes.xl),
              // Header
              _buildHeader(),
              const SizedBox(height: AppSizes.xl),
              // Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSizes.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.welcomeBack,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontXxl,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.textPrimary,
                          ),
                          validator: (v) => v?.isEmpty == true
                              ? context.l10n.enterYourEmail
                              : null,
                          decoration: InputDecoration(
                            hintText: context.l10n.emailAddress,
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        AppTextField(
                          label: '',
                          hint: context.l10n.password,
                          controller: _passwordController,
                          isPassword: true,
                          validator: (v) => v?.isEmpty == true
                              ? context.l10n.enterYourPassword
                              : null,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            child: Text(context.l10n.forgotPassword),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        AppButton(
                          label: context.l10n.login,
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: AppColors.divider),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.md,
                              ),
                              child: Text(
                                context.l10n.orContinueWith,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontSm,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: AppColors.divider),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.dontHaveAccount,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.signup),
                              child: Text(
                                context.l10n.signUp,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              Text(
                '© 2024 VacciTrack Systems. Secure Medical Compliance.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: const Icon(
            Icons.vaccines_rounded,
            color: AppColors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          context.l10n.appName,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Text(
          context.l10n.manageYourHealthRecordsSecurely,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontMd,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
