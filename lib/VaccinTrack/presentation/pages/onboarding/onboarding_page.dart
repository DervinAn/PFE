import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.child_care_rounded,
      backgroundColor: const Color(0xFFFFF3E0),
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      backgroundColor: const Color(0xFFE8F5E9),
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
    ),
    _OnboardingData(
      icon: Icons.verified_rounded,
      backgroundColor: const Color(0xFFE3F2FD),
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await LocalAppStorage.instance.setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  return _OnboardingSlide(data: _pages[index]);
                },
              ),
            ),

            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final isActive = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textTertiary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                );
              }),
            ),

            const SizedBox(height: AppSizes.xl),

            // Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.xl,
                0,
                AppSizes.xl,
                AppSizes.xl,
              ),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingSlide({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.md),
          // Illustration container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: data.backgroundColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Center(
                child: Icon(
                  data.icon,
                  size: 120,
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: AppSizes.fontDisplay,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: AppSizes.fontLg,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.backgroundColor,
    required this.title,
    required this.description,
  });
}
