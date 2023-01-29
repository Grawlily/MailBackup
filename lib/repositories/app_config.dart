import 'package:flutter/foundation.dart';
import 'package:mail_backup/utils/shared_preferences_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  String? host;
  int? port;
  bool? isSecure;
  String? userName;
  String? password;
  late SharedPreferences sp;

  static Future<AppConfig> getInstance() async {
    AppConfig appConfig = AppConfig();
    appConfig.sp = await SharedPreferences.getInstance();
    try {
      appConfig.host = getStringSafe(appConfig.sp, 'host');
      appConfig.port = getIntSafe(appConfig.sp, 'port');
      appConfig.isSecure = getBoolSafe(appConfig.sp, 'isSecure');
      appConfig.password = getStringSafe(appConfig.sp, 'password');
      appConfig.userName = getStringSafe(appConfig.sp, 'userName');
    } on PreferenceNotFound catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return appConfig;
  }

  String getHost() {
    return getStringSafe(sp, 'host');
  }

  int getPort() {
    return getIntSafe(sp, 'port');
  }

  bool getIsSecure() {
    return getBoolSafe(sp, 'isSecure');
  }

  String getUserName() {
    return getStringSafe(sp, 'userName');
  }

  String getPassword() {
    return getStringSafe(sp, 'password');
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
