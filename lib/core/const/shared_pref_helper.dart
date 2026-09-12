import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static SharedPreferences? _prefs;

  static const String _languageKey = 'selected_language';
  static const String _onboardingKey = 'is_onboarding_completed';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _bannerDataKey = 'banner_data';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(
    String accessToken, [
    String? refreshToken,
  ]) async {
    await _prefs?.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await _prefs?.setString(_refreshTokenKey, refreshToken);
    }
  }

  static String? getAccessToken() {
    return _prefs?.getString(_accessTokenKey);
  }

  static Future<void> removeAccessToken() async {
    await _prefs?.remove(_accessTokenKey);
  }

  static Future<void> removeRefreshToken() async {
    await _prefs?.remove(_refreshTokenKey);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  static Future<void> saveRole(String role) async {
    await _prefs?.setString(_userRoleKey, role);
  }

  static String? getUserRole() {
    return _prefs?.getString(_userRoleKey);
  }

  static Future<void> removeUserRole() async {
    await _prefs?.remove(_userRoleKey);
  }

  static Future<void> saveLanguage(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  static String? getLanguage() {
    return _prefs?.getString(_languageKey);
  }

  static Future<void> saveOnboardingCompleted(bool completed) async {
    await _prefs?.setBool(_onboardingKey, completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs?.getBool(_onboardingKey) ?? false;
  }

  static Future<void> saveBannerData(String bannerJson) async {
    await _prefs?.setString(_bannerDataKey, bannerJson);
  }

  static String? getBannerData() {
    return _prefs?.getString(_bannerDataKey);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
