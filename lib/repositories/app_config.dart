import 'package:flutter/foundation.dart';
import 'package:mail_backup/utils/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  String? host;
  int? port;
  bool? isSecure;
  String? userName;
  String? password;

  static Future<AppConfig> getInstance() async {
    AppConfig appConfig = AppConfig();
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      appConfig.host = getStringSafe(sp, 'host');
      appConfig.port = getIntSafe(sp, 'port');
      appConfig.isSecure = getBoolSafe(sp, 'isSecure');
      appConfig.password = getStringSafe(sp, 'password');
      appConfig.userName = getStringSafe(sp, 'userName');
    } on PreferenceNotFound catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return appConfig;
  }

  Future<void> save() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('host', host ?? '');
    await sp.setString('userName', userName ?? '');
    await sp.setString('password', password ?? '');
    await sp.setInt('port', port ?? 993);
    await sp.setBool('isSecure', isSecure ?? true);
  }
}
