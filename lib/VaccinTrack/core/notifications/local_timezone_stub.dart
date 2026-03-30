import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

Future<void> configureLocalTimeZone() async {
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.UTC);
}
