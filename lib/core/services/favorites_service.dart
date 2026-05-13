import 'api_service.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class FavoritesService {
  static const String _baseUrl = '/favorites';
  static const String _favoritesKey = 'user_favorites';

  /// Get user's favorites from backend
  static Future<List<Map<String, dynamic>>> getUserFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService.get(
        _baseUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> favoritesJson = response.data['data'];
      return favoritesJson.cast<Map<String, dynamic>>();
    } catch (e) {
      // Fallback to local storage if backend fails
      return await _getLocalFavorites();
    }
  }

  /// Add a cake to favorites (backend + local cache)
  static Future<bool> addToFavorites(String cakeId) async {
    try {
      await ApiService.post('$_baseUrl/$cakeId');

      // Update local cache
      await _addToLocalFavorites(cakeId);
      return true;
    } catch (e) {
      // Fallback to local storage only
      return await _addToLocalFavorites(cakeId);
    }
  }

  /// Remove a cake from favorites (backend + local cache)
  static Future<bool> removeFromFavorites(String cakeId) async {
    try {
      await ApiService.delete('$_baseUrl/$cakeId');

      // Update local cache
      await _removeFromLocalFavorites(cakeId);
      return true;
    } catch (e) {
      // Fallback to local storage only
      return await _removeFromLocalFavorites(cakeId);
    }
  }

  /// Toggle favorite status (backend + local cache)
  static Future<bool> toggleFavorite(String cakeId) async {
    try {
      final response = await ApiService.post('$_baseUrl/$cakeId/toggle');
      final isFavorited = response.data['data']['isFavorited'] ?? false;

      // Update local cache
      if (isFavorited) {
        await _addToLocalFavorites(cakeId);
      } else {
        await _removeFromLocalFavorites(cakeId);
      }

      // Invalidate cache to force refresh
      await CacheService.invalidateCache('favorites');

      return true;
    } catch (e) {
      // Fallback to local toggle
      final currentFavorites = await getFavoriteIds();
      if (currentFavorites.contains(cakeId)) {
        return await _removeFromLocalFavorites(cakeId);
      } else {
        return await _addToLocalFavorites(cakeId);
      }
    }
  }

  /// Check if a cake is favorited
  static Future<bool> isFavorited(String cakeId) async {
    try {
      final response = await ApiService.get('$_baseUrl/$cakeId/status');
      return response.data['data']['isFavorited'] ?? false;
    } catch (e) {
      // Fallback to local check
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.contains(cakeId);
    }
  }

  /// Get all favorite cake IDs (for backward compatibility)
  static Future<Set<String>> getFavoriteIds() async {
    try {
      // Try to load from cache first
      final cachedFavorites = await CacheService.getFavorites();
      if (cachedFavorites != null) {
        return cachedFavorites.toSet();
      }

      // Load from backend and cache
      final favorites = await getUserFavorites(limit: 1000);
      final favoriteIds = favorites
          .map((fav) => fav['cakeStyleId']?['_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      // Cache the data
      await CacheService.setFavorites(favoriteIds.toList());

      return favoriteIds;
    } catch (e) {
      return await _getLocalFavoriteIds();
    }
  }

  // Check if a cake is in favorites
  static Future<bool> isFavorite(String cakeId) async {
    try {
      final favorites = await getFavoriteIds();
      return favorites.contains(cakeId);
    } catch (e) {
// print('DEBUG: Error checking favorite status: $e');
      return false;
    }
  }

  // Clear all favorites
  static Future<bool> clearFavorites() async {
    try {
      await StorageService.remove(_favoritesKey);
      return true;
    } catch (e) {
// print('DEBUG: Error clearing favorites: $e');
      return false;
    }
  }

  // Get count of favorites
  static Future<int> getFavoritesCount() async {
    try {
      final favorites = await getUserFavorites(limit: 1000);
      return favorites.length;
    } catch (e) {
      final favoriteIds = await _getLocalFavoriteIds();
      return favoriteIds.length;
    }
  }

  // Local storage helper methods
  static Future<List<Map<String, dynamic>>> _getLocalFavorites() async {
    // Return empty list since local storage doesn't have full cake data
    return [];
  }

  static Future<Set<String>> _getLocalFavoriteIds() async {
    try {
      final favoritesList = StorageService.getStringList(_favoritesKey);
      return favoritesList?.toSet() ?? {};
    } catch (e) {
      return {};
    }
  }

  static Future<bool> _addToLocalFavorites(String cakeId) async {
    try {
      final currentFavorites = await _getLocalFavoriteIds();
      currentFavorites.add(cakeId);
      await StorageService.setStringList(
          _favoritesKey, currentFavorites.toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> _removeFromLocalFavorites(String cakeId) async {
    try {
      final currentFavorites = await _getLocalFavoriteIds();
      currentFavorites.remove(cakeId);
      await StorageService.setStringList(
          _favoritesKey, currentFavorites.toList());
      return true;
    } catch (e) {
      return false;
    }
  }
}
