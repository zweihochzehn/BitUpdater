import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  late final SharedPreferences sharedPrefs;

  Future<void> initSharedPreferences() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  Future<void> _setBool(String key, bool value) async {
    await sharedPrefs.setBool(key, value);
  }

  bool _getBool(String key) {
    return sharedPrefs.getBool(key) ?? false;
  }

  Future<void> _removeEntry(String key) async {
    await sharedPrefs.remove(key);
  }

  Future<void> _setInt(String key, int value) async {
    await sharedPrefs.setInt(key, value);
  }

  int _getInt(String key) {
    return sharedPrefs.getInt(key) ?? 0;
  }

  Future<void> setDismissedVersion(int value) async {
    await _setInt("dismissedVersion", value);
  }

  int getDismissedVersion() {
    return _getInt("dismissedVersion");
  }
}