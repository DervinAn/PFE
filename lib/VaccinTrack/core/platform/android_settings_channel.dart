import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AndroidSettingsChannel {
  AndroidSettingsChannel._();

  static const MethodChannel _channel = MethodChannel(
    'vaccitrack/android_settings',
  );

  static Future<bool> openNotificationSettings() {
    return _invoke('openNotificationSettings');
  }

  static Future<bool> openExactAlarmSettings() {
    return _invoke('openExactAlarmSettings');
  }

  static Future<bool> _invoke(String method) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      final result = await _channel.invokeMethod<bool>(method);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}

