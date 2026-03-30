import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

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
}
