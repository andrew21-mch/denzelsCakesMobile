import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure storage methods (now using SharedPreferences for compatibility)
  static Future<void> setSecureString(String key, String value) async {
    await _prefs.setString('secure_$key', value);
  }

  static Future<String?> getSecureString(String key) async {
    return _prefs.getString('secure_$key');
  }

  static Future<void> deleteSecureString(String key) async {
    await _prefs.remove('secure_$key');
  }

  static Future<void> clearSecureStorage() async {
    // Remove all keys that start with 'secure_'
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('secure_')) {
        await _prefs.remove(key);
      }
    }
  }

  // Regular storage methods (for non-sensitive data)
  static Future<void> setString(String key, String value) async {
// print('DEBUG: StorageService - Setting string for key: $key');
    await _prefs.setString(key, value);
// print('DEBUG: StorageService - String set successfully');
  }

  static Future<String?> getString(String key) async {
// print('DEBUG: StorageService - Getting string for key: $key');
    final value = _prefs.getString(key);
// print('DEBUG: StorageService - Retrieved value: $value');
    return value;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }

  // JSON storage methods
  static Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Authentication token methods
  static Future<void> setAccessToken(String token) async {
    await setSecureString(AppConstants.accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    return await getSecureString(AppConstants.accessTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await setSecureString(AppConstants.refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    return await getSecureString(AppConstants.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await deleteSecureString(AppConstants.accessTokenKey);
    await deleteSecureString(AppConstants.refreshTokenKey);
  }

  // User data methods
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    await setJson(AppConstants.userDataKey, userData);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    return await getJson(AppConstants.userDataKey);
  }

  static Future<void> clearUserData() async {
    await remove(AppConstants.userDataKey);
  }

  // Cart data methods
  static Future<void> setCartData(Map<String, dynamic> cartData) async {
    await setJson(AppConstants.cartDataKey, cartData);
  }

  static Future<Map<String, dynamic>?> getCartData() async {
    return await getJson(AppConstants.cartDataKey);
  }

  static Future<void> clearCartData() async {
    await remove(AppConstants.cartDataKey);
  }

  // App settings methods
  static Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await setBool('first_launch', isFirstLaunch);
  }

  static bool isFirstLaunch() {
    return getBool('first_launch') ?? true;
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    await setBool('onboarding_completed', completed);
  }

  static bool isOnboardingCompleted() {
    return getBool('onboarding_completed') ?? false;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await setBool('notifications_enabled', enabled);
  }

  static bool areNotificationsEnabled() {
    return getBool('notifications_enabled') ?? true;
  }

  // Cache methods
  static Future<void> setCacheData(String key, Map<String, dynamic> data,
      {Duration? expiry}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await setJson('cache_$key', cacheData);
  }

  static Future<Map<String, dynamic>?> getCacheData(String key) async {
    final cacheData = await getJson('cache_$key');
    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int?;
      final expiry = cacheData['expiry'] as int?;

      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (expiry != null && (now - timestamp) > expiry) {
          // Cache expired
          await remove('cache_$key');
          return null;
        }
        return cacheData['data'] as Map<String, dynamic>?;
      }
    }
    return null;
  }

  static Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await remove(key);
      }
    }
  }

  // Complete logout cleanup
  static Future<void> logout() async {
    await clearTokens();
    await clearUserData();
    await clearCartData();
    await clearCache();
  }
}
