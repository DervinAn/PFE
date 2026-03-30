import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Invalid credentials or no local account found. Please sign up first.',
        ),
      ),
    );
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
                        color: AppColors.textPrimary.withOpacity(0.05),
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
                        const Text(
                          'Welcome back',
                          style: TextStyle(
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
                          validator: (v) =>
                              v?.isEmpty == true ? 'Enter your email' : null,
                          decoration: const InputDecoration(
                            hintText: 'Email address',
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        AppTextField(
                          label: '',
                          hint: 'Password',
                          controller: _passwordController,
                          isPassword: true,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Enter your password' : null,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Forgot password?'),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        AppButton(
                          label: 'Login',
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
                                'Or continue with',
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
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.signup),
                              child: const Text(
                                'Sign up',
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
              // Decorative card at bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB8D4F0), Color(0xFF8BB8E8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
        const Text(
          'VacciTrack',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontXxl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        const Text(
          'Manage your health records securely',
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
