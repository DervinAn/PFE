import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
  final _phoneController = TextEditingController();
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
    if (_passwordStrength < 0.34) return 'Weak';
    if (_passwordStrength < 0.67) return 'Medium';
    return 'Strong';
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
        const SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }
    final emailTaken = await LocalAppStorage.instance.emailExists(
      _emailController.text.trim(),
    );
    if (emailTaken) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This email already exists. Please login instead.'),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await LocalAppStorage.instance.saveUser(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
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
    _phoneController.dispose();
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
                  color: AppColors.textPrimary.withOpacity(0.05),
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
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Create Account',
                            style: TextStyle(
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
                  const Text(
                    'Join VacciTrack',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontXxl,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  const Text(
                    AppStrings.signupSubtitle,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Full Name
                  AppTextField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    controller: _nameController,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Email
                  AppTextField(
                    label: 'Email Address',
                    hint: 'email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Enter email' : null,
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Phone
                  AppTextField(
                    label: 'Phone Number',
                    hint: '+1 (555) 000-0000',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Password
                  AppTextField(
                    label: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) =>
                        v != null && v.length < 8 ? 'Min 8 characters' : null,
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
                          const TextSpan(
                            text: 'Strength: ',
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
                          const TextSpan(
                            text: '. Use 8+ characters with symbols.',
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
                    label: 'Confirm Password',
                    controller: _confirmController,
                    isPassword: true,
                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: AppColors.textTertiary,
                    ),
                    validator: (v) => v != _passwordController.text
                        ? 'Passwords do not match'
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
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
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
                    label: 'Create Account',
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
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Text(
                          'Log in',
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
                        'Secure 256-bit encryption active',
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
