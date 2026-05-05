import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'VaccinTrack/core/di/injection.dart';
import 'VaccinTrack/core/localization/app_localization.dart';
import 'VaccinTrack/core/notifications/local_notification_service.dart';
import 'VaccinTrack/core/theme/app_theme.dart';
import 'VaccinTrack/core/utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await LocalNotificationService.instance.init();
  await AppLocaleController.instance.load();
  await LocalNotificationService.instance.resyncVaccineReminders();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const VacciTrackApp());
}

class VacciTrackApp extends StatelessWidget {
  const VacciTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppLocaleController.instance,
      builder: (context, child) {
        final localeController = AppLocaleController.instance;
        return MaterialApp.router(
          title: 'VacciTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: appRouter,
        );
      },
    );
  }
}
