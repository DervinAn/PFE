import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  String _loadingText = 'Initializing secure vault...';

  final List<String> _loadingSteps = [
    'Initializing secure vault...',
    'Loading health records...',
    'Syncing vaccine schedule...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressController.addListener(() {
      final v = _progressController.value;
      String text;
      if (v < 0.3) {
        text = _loadingSteps[0];
      } else if (v < 0.6) {
        text = _loadingSteps[1];
      } else if (v < 0.85) {
        text = _loadingSteps[2];
      } else {
        text = _loadingSteps[3];
      }
      if (text != _loadingText) {
        setState(() => _loadingText = text);
      }
    });

    _progressController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        _resolveInitialRoute();
      });
    });
  }

  Future<void> _resolveInitialRoute() async {
    final storage = LocalAppStorage.instance;
    final onboardingDone = await storage.isOnboardingCompleted();
    final loggedIn = await storage.isLoggedIn();
    final hasAccount = await storage.hasSavedAccount();
    if (!mounted) return;
    if (loggedIn && hasAccount) {
      context.go(AppRoutes.home);
      return;
    }
    if (onboardingDone) {
      context.go(AppRoutes.login);
      return;
    }
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    _buildLogo(),
                    const SizedBox(height: AppSizes.xl),
                    // App Name
                    const Text(
                      'VacciTrack',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontMd,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      AppStrings.appSlogan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontMd,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress area
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.xl,
                  0,
                  AppSizes.xl,
                  AppSizes.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _loadingText,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontMd,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (_, __) => Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontMd,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Version
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.xl),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        AppStrings.appVersion,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
        ),
      ),
    );
  }
}
