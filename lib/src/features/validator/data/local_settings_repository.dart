import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsRepository {
  static const _apiBaseUrlKey = 'validator.api_base_url';

  Future<String?> getApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiBaseUrlKey);
  }

  Future<void> saveApiBaseUrl(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiBaseUrlKey, value);
  }
}
