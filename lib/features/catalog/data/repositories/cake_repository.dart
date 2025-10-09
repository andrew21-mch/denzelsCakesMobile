import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/cake_model.dart';

class CakeRepository {
  // Get all cakes with optional search and filters
  static Future<CakeListResponse> getCakes({
    String? search,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    bool? isAvailable,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await ApiService.get(
        '/cakes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Extract the data from the backend response structure
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          return CakeListResponse.fromJson({
            'data': responseData['data'],
            'pagination': responseData['pagination'],
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load cakes: ${response.statusCode}');
      }
    } catch (e) {
// print('DEBUG: Repository error loading cakes: $e');
      rethrow;
    }
  }

  // Get featured cakes
  static Future<CakeListResponse> getFeaturedCakes({
    int limit = 10,
  }) async {
    try {
      return await getCakes(
        limit: limit,
        isAvailable: true,
      );
    } catch (e) {
// print('DEBUG: Repository error loading featured cakes: $e');
      rethrow;
    }
  }

  // Get cakes by category/tag
  static Future<CakeListResponse> getCakesByCategory({
    required String category,
    int limit = 20,
  }) async {
    try {
      return await getCakes(
        tags: [category],
        limit: limit,
        isAvailable: true,
      );
    } catch (e) {
// print('DEBUG: Repository error loading cakes by category: $e');
      rethrow;
    }
  }

  // Search cakes
  static Future<CakeListResponse> searchCakes({
    required String query,
    int limit = 20,
  }) async {
    try {
      return await getCakes(
        search: query,
        limit: limit,
        isAvailable: true,
      );
    } catch (e) {
// print('DEBUG: Repository error searching cakes: $e');
      rethrow;
    }
  }

  // Get trending cakes
  static Future<CakeListResponse> getTrendingCakes({
    int limit = 10,
  }) async {
    try {
      return await getCakes(
        limit: limit,
        isAvailable: true,
      );
    } catch (e) {
// print('DEBUG: Repository error loading trending cakes: $e');
      rethrow;
    }
  }

  // Get a single cake by ID
  static Future<CakeStyle> getCakeById(String id) async {
    try {
// print('DEBUG: Repository - Fetching cake with ID: $id');
      final response = await ApiService.get('/cakes/$id');
// print('DEBUG: Repository - Response status: ${response.statusCode}');
// print('DEBUG: Repository - Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
// print('DEBUG: Repository - Parsing cake data...');
          final cake = CakeStyle.fromJson(responseData['data']);
// print('DEBUG: Repository - Successfully parsed cake: ${cake.title}');
          return cake;
        } else {
          throw Exception('Invalid response format: $responseData');
        }
      } else {
        throw Exception('Failed to load cake: ${response.statusCode}');
      }
    } catch (e) {
// print('DEBUG: Repository error loading cake by ID: $e');
      rethrow;
    }
  }

  // Get available categories (tags)
  static Future<List<String>> getAvailableCategories() async {
    // Return the fixed categories that the business wants
    return ['Birthday', 'Wedding', 'Anniversary', 'Baby Shower', 'Faith Celebrations'];
  }

  // Get price range
  static Future<Map<String, double>> getPriceRange() async {
    try {
      final cakes = await getCakes(limit: 100);

      if (cakes.data.isEmpty) {
        return {'min': 0.0, 'max': 100.0};
      }

      double minPrice = cakes.data.first.basePrice;
      double maxPrice = cakes.data.first.basePrice;

      for (final cake in cakes.data) {
        if (cake.basePrice < minPrice) minPrice = cake.basePrice;
        if (cake.basePrice > maxPrice) maxPrice = cake.basePrice;
      }

      return {'min': minPrice, 'max': maxPrice};
    } catch (e) {
// print('DEBUG: Repository error loading price range: $e');
      return {'min': 0.0, 'max': 100.0};
    }
  }

  // Cache management
  static Future<void> cacheCakes(List<CakeStyle> cakes) async {
    try {
      final cakeData = cakes.map((cake) => cake.toJson()).toList();
      await StorageService.setString('cached_cakes', cakeData.toString());
    } catch (e) {
// print('DEBUG: Repository error caching cakes: $e');
    }
  }

  static Future<List<CakeStyle>> getCachedCakes() async {
    try {
      // final cacheString = StorageService.getString('cached_cakes');
      // For now, return empty list as caching is not critical
      // TODO: Implement proper JSON list parsing if needed
      return [];
    } catch (e) {
// print('DEBUG: Repository error loading cached cakes: $e');
      return [];
    }
  }

  // Clear cache
  static Future<void> clearCache() async {
    try {
      await StorageService.remove('cached_cakes');
    } catch (e) {
// print('DEBUG: Repository error clearing cache: $e');
    }
  }

  // Calculate price with size multiplier
  static double calculatePrice(CakeStyle cake, CakeSize? size) {
    try {
      if (size != null) {
        // Use override price if available, otherwise use base price with multiplier
        if (size.basePriceOverride != null) {
          return size.basePriceOverride!;
        } else {
          final multiplier = size.multiplier;
          final safeBasePrice = cake.basePrice;
          return safeBasePrice * multiplier;
        }
      }
      return cake.basePrice;
    } catch (e) {
// print('DEBUG: Repository error calculating price: $e');
      return cake.basePrice;
    }
  }

  // Get formatted prep time
  static String getFormattedPrepTime(int prepTimeMinutes) {
    try {
      if (prepTimeMinutes < 60) {
        return '${prepTimeMinutes}min';
      } else {
        final hours = prepTimeMinutes ~/ 60;
        final minutes = prepTimeMinutes % 60;
        if (minutes == 0) {
          return '${hours}h';
        } else {
          return '${hours}h ${minutes}min';
        }
      }
    } catch (e) {
// print('DEBUG: Repository error formatting prep time: $e');
      return '${prepTimeMinutes}min';
    }
  }

  // Get cake image URL (first available image)
  static String getCakeImageUrl(CakeStyle cake) {
    try {
      if (cake.images.isNotEmpty) {
        return cake.images.first;
      }
      return '';
    } catch (e) {
// print('DEBUG: Repository error getting image URL: $e');
      return '';
    }
  }
}
