import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2A7BE4);
  static const Color primaryDark = Color(0xFF1A5FBE);
  static const Color primaryLight = Color(0xFFEBF3FF);
  static const Color primaryContainer = Color(0xFFD6E8FF);

  // Secondary
  static const Color secondary = Color(0xFF34C97B);
  static const Color secondaryLight = Color(0xFFE8FAF1);

  // Accent
  static const Color accent = Color(0xFFF5A623);
  static const Color accentLight = Color(0xFFFFF4E0);

  // Status Colors
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFE8F8F1);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFF8E7);
  static const Color error = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFFF0F0);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEFF6FF);

  // Vaccine Status
  static const Color done = Color(0xFF27AE60);
  static const Color overdue = Color(0xFFE53E3E);
  static const Color dueSoon = Color(0xFFF59E0B);
  static const Color upcoming = Color(0xFF6B7280);
  static const Color pending = Color(0xFFF59E0B);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color divider = Color(0xFFE8EDF2);

  // Text
  static const Color textPrimary = Color(0xFF1A2332);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A7BE4), Color(0xFF1A5FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFEBF3FF), Color(0xFFD6E8FF), Color(0xFFEBF3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardBlueGradient = LinearGradient(
    colors: [Color(0xFF2A7BE4), Color(0xFF1A5FBE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSizes {
  AppSizes._();

  // Padding / Margin
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 100.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Font sizes
  static const double fontXs = 10.0;
  static const double fontSm = 12.0;
  static const double fontMd = 14.0;
  static const double fontLg = 16.0;
  static const double fontXl = 18.0;
  static const double fontXxl = 22.0;
  static const double fontDisplay = 28.0;
  static const double fontHero = 36.0;

  // Component heights
  static const double buttonHeight = 56.0;
  static const double inputHeight = 54.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 60.0;
}

class AppStrings {
  AppStrings._();

  static const String appName = 'VacciTrack';
  static const String appTagline = 'HEALTHCARE ASSISTANT';
  static const String appSlogan = 'Protect your child, one vaccine at a time';
  static const String appVersion = 'VACCITRACK V1.0.0';

  // Onboarding
  static const String onboarding1Title = 'Track every vaccine';
  static const String onboarding1Desc =
      "Stay on top of your child's immunization schedule with ease and accuracy.";
  static const String onboarding2Title = 'Never miss a dose';
  static const String onboarding2Desc =
      'Get smart reminders before each vaccination appointment.';
  static const String onboarding3Title = 'Digital health records';
  static const String onboarding3Desc =
      'Store and share official vaccination certificates instantly.';

  // Auth
  static const String loginTitle = 'Welcome back';
  static const String signupTitle = 'Join VacciTrack';
  static const String signupSubtitle =
      'Securely track your vaccinations by creating an account.';

  // Vaccine Status Labels
  static const String statusDone = 'DONE';
  static const String statusOverdue = 'OVERDUE';
  static const String statusDueSoon = 'DUE SOON';
  static const String statusUpcoming = 'UPCOMING';
  static const String statusPending = 'PENDING';
  static const String statusCompleted = 'COMPLETED';
}
