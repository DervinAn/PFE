import 'package:go_router/go_router.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/signup_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/child/child_detail_page.dart';
import '../../presentation/pages/child/add_child_profile_page.dart';
import '../../presentation/pages/vaccine/vaccine_schedule_page.dart';
import '../../presentation/pages/record/vaccination_card_page.dart';
import '../../presentation/pages/record/vaccination_history_page.dart';
import '../../presentation/pages/record/record_vaccination_page.dart';
import '../../presentation/pages/notification/notifications_page.dart';
import '../../presentation/pages/guide/guide_page.dart';
import '../../presentation/pages/profile/profile_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String childrenProfiles = '/children-profiles';
  static const String childDetail = '/child/:id';
  static const String addChildProfile = '/child-profile/add';
  static const String editChildProfile = '/child-profile/edit/:id';
  static const String vaccineSchedule = '/vaccine-schedule/:childId';
  static const String vaccinationCard = '/vaccination-card/:childId';
  static const String vaccinationHistory = '/vaccination-history';
  static const String recordVaccination = '/record-vaccination';
  static const String notifications = '/notifications';
  static const String guide = '/guide';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const ChildDetailPage(),
    ),
    GoRoute(
      path: AppRoutes.childrenProfiles,
      name: 'childrenProfiles',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.childDetail,
      name: 'childDetail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ChildDetailPage(childId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.addChildProfile,
      name: 'addChildProfile',
      builder: (context, state) => const AddChildProfilePage(),
    ),
    GoRoute(
      path: AppRoutes.editChildProfile,
      name: 'editChildProfile',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddChildProfilePage(childId: id);
      },
    ),
    GoRoute(
      path: AppRoutes.vaccineSchedule,
      name: 'vaccineSchedule',
      builder: (context, state) {
        final childId = state.pathParameters['childId'] ?? '';
        return VaccineSchedulePage(childId: childId);
      },
    ),
    GoRoute(
      path: AppRoutes.vaccinationCard,
      name: 'vaccinationCard',
      builder: (context, state) {
        final childId = state.pathParameters['childId'] ?? '';
        return VaccinationCardPage(childId: childId);
      },
    ),
    GoRoute(
      path: AppRoutes.vaccinationHistory,
      name: 'vaccinationHistory',
      builder: (context, state) => const VaccinationHistoryPage(),
    ),
    GoRoute(
      path: AppRoutes.recordVaccination,
      name: 'recordVaccination',
      builder: (context, state) => RecordVaccinationPage(
        preselectedChildId: state.uri.queryParameters['childId'],
        preselectedDoseId: state.uri.queryParameters['doseId'],
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: AppRoutes.guide,
      name: 'guide',
      builder: (context, state) => const GuidePage(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
