import 'package:shared_preferences/shared_preferences.dart';

class PreferenceNotFound implements Exception {
  String key;
  PreferenceNotFound(this.key);
}

String getStringSafe(SharedPreferences sp, String key) {
  String? value = sp.getString(key);
  if (value is! String) {
    throw PreferenceNotFound(key);
  }

  return value;
}

int getIntSafe(SharedPreferences sp, String key) {
  int? value = sp.getInt(key);
  if (value is! int) {
    throw PreferenceNotFound(key);
  }

  return value;
}

double getDoubleSafe(SharedPreferences sp, String key) {
  var value = sp.getDouble(key);
  if (value is! double) {
    throw PreferenceNotFound(key);
  }

  return value;
}

bool getBoolSafe(SharedPreferences sp, String key) {
  bool? value = sp.getBool(key);
  if (value is! bool) {
    throw PreferenceNotFound(key);
  }

  return value;
}

List<String> getStringListSafe(SharedPreferences sp, String key) {
  List<String>? value = sp.getStringList(key);
  if (value is! List<String>) {
    throw PreferenceNotFound(key);
  }

  return value;
}
