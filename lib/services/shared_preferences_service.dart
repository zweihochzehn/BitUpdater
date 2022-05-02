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

  Future<void> setNonForcedUpdateAllowed(bool isAllowed) async {
    _setBool("isNonForcedUpdateAllowed", isAllowed);
  }

  bool getNonForcedUpdateAllowed() {
    return _getBool("isNonForcedUpdateAllowed");
  }
}