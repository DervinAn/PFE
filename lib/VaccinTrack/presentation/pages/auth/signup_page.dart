import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final p = _passwordController.text;
    double strength = 0;
    if (p.length >= 8) strength += 0.33;
    if (p.contains(RegExp(r'[A-Z]'))) strength += 0.33;
    if (p.contains(RegExp(r'[0-9!@#$%^&*]'))) strength += 0.34;
    setState(() => _passwordStrength = strength);
  }

  String get _strengthLabel {
    final l10n = AppLocaleController.instance.l10n;
    if (_passwordStrength < 0.34) return l10n.weak;
    if (_passwordStrength < 0.67) return l10n.medium;
    return l10n.strong;
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.34) return AppColors.error;
    if (_passwordStrength < 0.67) return AppColors.warning;
    return AppColors.success;
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.pleaseAgreeToTermsAndConditions)),
      );
      return;
    }
    final emailTaken = await LocalAppStorage.instance.emailExists(
      _emailController.text.trim(),
    );
    if (emailTaken) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.thisEmailAlreadyExistsPleaseLoginInstead),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await LocalAppStorage.instance.saveUser(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    await LocalAppStorage.instance.setOnboardingCompleted(true);
    await LocalAppStorage.instance.setLoggedIn(true);
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSizes.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            context.l10n.createAccount,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontXl,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(
                      Icons.vaccines_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    context.l10n.joinVacciTrack,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    context.l10n.signupSubtitle,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Full Name
                  AppTextField(
                    label: context.l10n.fullName,
                    hint: 'John Doe',
                    controller: _nameController,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? context.l10n.enterYourName : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Email
                  AppTextField(
                    label: context.l10n.emailAddress,
                    hint: 'email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) => v?.isEmpty == true
                        ? context.l10n.enterYourEmailAddress
                        : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Password
                  AppTextField(
                    label: context.l10n.password,
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) => v != null && v.length < 8
                        ? context.l10n.use8PlusCharactersWithSymbols
                        : null,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  // Strength bar
                  if (_passwordController.text.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(_strengthColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${context.l10n.strength}: ',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: _strengthLabel,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontSm,
                              fontWeight: FontWeight.w700,
                              color: _strengthColor,
                            ),
                          ),
                          TextSpan(
                            text:
                                '. ${context.l10n.use8PlusCharactersWithSymbols}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                  ],

                  // Confirm Password
                  AppTextField(
                    label: context.l10n.confirmPassword,
                    controller: _confirmController,
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) => v != _passwordController.text
                        ? context.l10n.passwordsDoNotMatch
                        : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Terms checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusXs,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: context.l10n.agreeToThe,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: context.l10n.termsAndConditions,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: context.l10n.andWord,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: context.l10n.privacyPolicy,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  AppButton(
                    label: context.l10n.createAccount,
                    onPressed: _signup,
                    isLoading: _isLoading,
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.alreadyHaveAccount,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          context.l10n.logIn,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        context.l10n.secureEncryptionActive,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
