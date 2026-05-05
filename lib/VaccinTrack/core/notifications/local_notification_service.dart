import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../localization/app_localization.dart';
import '../storage/local_app_storage.dart';
import '../../domain/entities/vaccine_entity.dart';
import 'local_timezone.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const String _testChannelId = 'vaccitrack_test_channel';
  static const String _testChannelName = 'VacciTrack Test Notifications';
  static const String _testChannelDesc =
      'Manual test notifications from profile settings';
  static const String _vaccineChannelId = 'vaccitrack_vaccine_channel';
  static const String _vaccineChannelName = 'VacciTrack Vaccine Reminders';
  static const String _vaccineChannelDesc =
      'Automatic reminders for vaccination due dates';

  Future<void> init() async {
    if (_initialized) return;

    await configureLocalTimeZone();

    const android = AndroidInitializationSettings('ic_stat_vaccitrack');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios, macOS: ios),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _testChannelId,
        _testChannelName,
        description: _testChannelDesc,
        importance: Importance.max,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _vaccineChannelId,
        _vaccineChannelName,
        description: _vaccineChannelDesc,
        importance: Importance.max,
      ),
    );

    final canScheduleExact = await androidPlugin
        ?.canScheduleExactNotifications();
    if (canScheduleExact == false) {
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _initialized = true;
  }

  Future<int> scheduleTestNotification({
    required DateTime scheduledAt,
    String title = 'VacciTrack Test Reminder',
    String body = 'Scheduled notification fired successfully.',
  }) async {
    await init();
    final now = DateTime.now();
    final when = scheduledAt.isAfter(now)
        ? scheduledAt
        : now.add(const Duration(seconds: 2));

    final notificationsEnabled =
        await _ensureAndroidNotificationsPermission();
    if (!notificationsEnabled) {
      throw StateError(
        'Notification permission is required before scheduling reminders.',
      );
    }

    final id = when.millisecondsSinceEpoch.remainder(1000000);
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    final canScheduleExact = await _ensureAndroidExactAlarmPermission();
    final scheduleMode = canScheduleExact == false
        ? AndroidScheduleMode.inexactAllowWhileIdle
        : AndroidScheduleMode.exactAllowWhileIdle;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _testChannelId,
        _testChannelName,
        channelDescription: _testChannelDesc,
        icon: 'ic_stat_vaccitrack',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: scheduleMode,
    );
    return id;
  }

  Future<int> scheduleVaccineReminder({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
  }) async {
    await init();
    final now = DateTime.now();
    final when = scheduledAt.isAfter(now)
        ? scheduledAt
        : now.add(const Duration(seconds: 2));
    final notificationsEnabled =
        await _ensureAndroidNotificationsPermission();
    if (!notificationsEnabled) {
      throw StateError(
        'Notification permission is required before scheduling reminders.',
      );
    }
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    final canScheduleExact = await _ensureAndroidExactAlarmPermission();
    final scheduleMode = canScheduleExact == false
        ? AndroidScheduleMode.inexactAllowWhileIdle
        : AndroidScheduleMode.exactAllowWhileIdle;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _vaccineChannelId,
        _vaccineChannelName,
        channelDescription: _vaccineChannelDesc,
        icon: 'ic_stat_vaccitrack',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: scheduleMode,
    );
    return id;
  }

  Future<void> showNowTestNotification({
    String title = 'VacciTrack Test Reminder',
    String body = 'Immediate notification test fired successfully.',
  }) async {
    await init();
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1000000);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _testChannelId,
        _testChannelName,
        channelDescription: _testChannelDesc,
        icon: 'ic_stat_vaccitrack',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<int> getPendingCount() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.length;
  }

  Future<void> cancelNotification(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  Future<bool?> canScheduleExactAlarms() async {
    await init();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return androidPlugin?.canScheduleExactNotifications();
  }

  Future<bool> _ensureAndroidNotificationsPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true;

    final enabled = await androidPlugin.areNotificationsEnabled();
    if (enabled == true) return true;

    final granted = await androidPlugin.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<bool> _ensureAndroidExactAlarmPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return true;

    final canScheduleExact = await androidPlugin.canScheduleExactNotifications();
    if (canScheduleExact == true) return true;

    final granted = await androidPlugin.requestExactAlarmsPermission();
    return granted ?? false;
  }

  int reminderIdFor(String key) {
    var hash = 0x811c9dc5;
    for (final unit in key.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  DateTime reminderTimeFor(DateTime dueDate) {
    return DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
  }

  Future<void> resyncVaccineReminders() async {
    await init();

    final enabled = await LocalAppStorage.instance.getNotificationsEnabled();
    final previousKeys = await LocalAppStorage.instance
        .getScheduledVaccineReminderKeys();

    if (!enabled) {
      for (final key in previousKeys) {
        await cancelNotification(reminderIdFor(key));
      }
      await LocalAppStorage.instance.clearScheduledVaccineReminderKeys();
      return;
    }

    final l10n = AppLocaleController.instance.l10n;
    final children = await LocalAppStorage.instance.getChildren();
    final desiredKeys = <String>{};
    final now = DateTime.now();

    for (final child in children) {
      final schedule = await LocalAppStorage.instance.getComputedSchedule(
        child.id,
      );
      for (final group in schedule) {
        for (final vaccine in group.vaccines) {
          if (vaccine.status == VaccineStatus.done) continue;
          if (vaccine.windowMissed) continue;
          final scheduledDate = vaccine.scheduledDate;
          if (scheduledDate == null) continue;

          final reminderAt = reminderTimeFor(scheduledDate);
          if (!reminderAt.isAfter(now)) continue;

          final doseKey = '${child.id}|${vaccine.plannedDoseId ?? vaccine.id}';
          final dueLabel =
              '${reminderAt.day}/${reminderAt.month}/${reminderAt.year}';
          final body =
              '${vaccine.name} • ${l10n.vaccineReminderDueOn} $dueLabel. ${l10n.openVaccinationCalendar}';
          try {
            await scheduleVaccineReminder(
              id: reminderIdFor(doseKey),
              scheduledAt: reminderAt,
              title: '${l10n.vaccineReminderTitle}: ${child.name}',
              body: body,
            );
            desiredKeys.add(doseKey);
          } catch (_) {
            // Skip reminders we cannot schedule right now; the next sync may succeed.
          }
        }
      }
    }

    for (final key in previousKeys.difference(desiredKeys)) {
      await cancelNotification(reminderIdFor(key));
    }
    await LocalAppStorage.instance.setScheduledVaccineReminderKeys(desiredKeys);
  }
}
