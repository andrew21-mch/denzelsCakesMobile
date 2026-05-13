import 'storage_service.dart';

class CacheService {
  // Cache duration constants
  static const Duration shortCache = Duration(minutes: 2);
  static const Duration mediumCache = Duration(minutes: 5);
  static const Duration longCache = Duration(minutes: 15);
  static const Duration veryLongCache = Duration(hours: 1);

  // Cache keys
  static const String _featuredCakesKey = 'featured_cakes';
  static const String _categoriesKey = 'categories';
  static const String _userProfileKey = 'user_profile';
  static const String _userAddressesKey = 'user_addresses';
  static const String _paymentMethodsKey = 'payment_methods';
  static const String _favoritesKey = 'favorites';
  static const String _countriesKey = 'countries';

  /// Set cached data with expiry
  static Future<void> setCacheData(String key, dynamic data,
      {Duration? expiry}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await StorageService.setJson('cache_$key', cacheData);
  }

  /// Get cached data if not expired
  static Future<dynamic> getCacheData(String key) async {
    final cacheData = await StorageService.getJson('cache_$key');

    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int?;
      final expiry = cacheData['expiry'] as int?;

      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (expiry != null && (now - timestamp) > expiry) {
          // Cache expired, remove it
          await StorageService.remove('cache_$key');
          return null;
        }
        return cacheData['data'];
      }
    }
    return null;
  }

  /// Clear specific cache
  static Future<void> clearCache(String key) async {
    await StorageService.remove('cache_$key');
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    await StorageService.clearCache();
  }

  /// Check if cache exists and is valid
  static Future<bool> isCacheValid(String key) async {
    final cacheData = await StorageService.getJson('cache_$key');

    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int?;
      final expiry = cacheData['expiry'] as int?;

      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (expiry != null && (now - timestamp) > expiry) {
          return false; // Cache expired
        }
        return true; // Cache is valid
      }
    }
    return false; // No cache
  }

  /// Get cache age in minutes
  static Future<int?> getCacheAge(String key) async {
    final cacheData = await StorageService.getJson('cache_$key');

    if (cacheData != null) {
      final timestamp = cacheData['timestamp'] as int?;
      if (timestamp != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        return ((now - timestamp) / 60000).round(); // Convert to minutes
      }
    }
    return null;
  }

  // Featured cakes cache
  static Future<void> setFeaturedCakes(List<dynamic> cakes) async {
    await setCacheData(_featuredCakesKey, cakes, expiry: mediumCache);
  }

  static Future<List<dynamic>?> getFeaturedCakes() async {
    final cached = await getCacheData(_featuredCakesKey);
    return cached != null ? List<dynamic>.from(cached) : null;
  }

  // Categories cache
  static Future<void> setCategories(List<String> categories) async {
    await setCacheData(_categoriesKey, categories, expiry: longCache);
  }

  static Future<List<String>?> getCategories() async {
    final cached = await getCacheData(_categoriesKey);
    return cached != null ? List<String>.from(cached) : null;
  }

  // User profile cache
  static Future<void> setUserProfile(Map<String, dynamic> profile) async {
    await setCacheData(_userProfileKey, profile, expiry: mediumCache);
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    return await getCacheData(_userProfileKey);
  }

  // User addresses cache
  static Future<void> setUserAddresses(List<dynamic> addresses) async {
    await setCacheData(_userAddressesKey, addresses, expiry: mediumCache);
  }

  static Future<List<dynamic>?> getUserAddresses() async {
    final cached = await getCacheData(_userAddressesKey);
    return cached != null ? List<dynamic>.from(cached) : null;
  }

  // Payment methods cache
  static Future<void> setPaymentMethods(List<dynamic> methods) async {
    await setCacheData(_paymentMethodsKey, methods, expiry: mediumCache);
  }

  static Future<List<dynamic>?> getPaymentMethods() async {
    final cached = await getCacheData(_paymentMethodsKey);
    return cached != null ? List<dynamic>.from(cached) : null;
  }

  // Favorites cache
  static Future<void> setFavorites(List<String> favorites) async {
    await setCacheData(_favoritesKey, favorites, expiry: shortCache);
  }

  static Future<List<String>?> getFavorites() async {
    final cached = await getCacheData(_favoritesKey);
    return cached != null ? List<String>.from(cached) : null;
  }

  // Countries cache
  static Future<void> setCountries(List<dynamic> countries) async {
    await setCacheData(_countriesKey, countries, expiry: veryLongCache);
  }

  static Future<List<dynamic>?> getCountries() async {
    final cached = await getCacheData(_countriesKey);
    return cached != null ? List<dynamic>.from(cached) : null;
  }

  /// Invalidate specific cache when data is updated
  static Future<void> invalidateCache(String key) async {
    await clearCache(key);
  }

  /// Invalidate related caches when user data changes
  static Future<void> invalidateUserData() async {
    await clearCache(_userProfileKey);
    await clearCache(_userAddressesKey);
    await clearCache(_paymentMethodsKey);
    await clearCache(_favoritesKey);
  }

  /// Invalidate catalog data when it changes
  static Future<void> invalidateCatalogData() async {
    await clearCache(_featuredCakesKey);
    await clearCache(_categoriesKey);
  }
}
