import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void> configureLocalTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final timeZoneName =
        await FlutterNativeTimezoneLatest.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (_) {
    tz.setLocalLocation(tz.UTC);
  }
}
