import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';

class AdminApiService {
  // CAKE MANAGEMENT

  /// Upload image to server and get URL
  static Future<String> uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        'folder': 'cakes',
      });

      final response = await ApiService.post(
        AppConstants.mediaUploadEndpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data']['url'] as String;
        } else {
          throw Exception(data['message'] ?? 'Failed to upload image');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
// print('Image upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Create new cake style
  static Future<Map<String, dynamic>> createCake(
      Map<String, dynamic> cakeData) async {
    try {
      final response = await ApiService.post(
        AppConstants.cakesEndpoint,
        data: cakeData,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to create cake');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to create cake');
      }
    } catch (e) {
// print('Create cake error: $e');
      throw Exception('Failed to create cake: $e');
    }
  }

  /// Get all cakes (admin view)
  static Future<List<Map<String, dynamic>>> getAllCakes() async {
    try {
      final response = await ApiService.get(AppConstants.cakesEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch cakes');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch cakes');
      }
    } catch (e) {
// print('Get cakes error: $e');
      throw Exception('Failed to fetch cakes: $e');
    }
  }

  /// Update cake availability
  static Future<void> updateCakeAvailability(
      String cakeId, bool isAvailable) async {
    try {
      final response = await ApiService.put(
        '${AppConstants.cakesEndpoint}/$cakeId',
        data: {'isAvailable': isAvailable},
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update cake');
      }
    } catch (e) {
// print('Update cake availability error: $e');
      throw Exception('Failed to update cake: $e');
    }
  }

  /// Delete cake
  static Future<void> deleteCake(String cakeId) async {
    try {
      final response =
          await ApiService.delete('${AppConstants.cakesEndpoint}/$cakeId');

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to delete cake');
      }
    } catch (e) {
// print('Delete cake error: $e');
      throw Exception('Failed to delete cake: $e');
    }
  }

  // ORDER MANAGEMENT

  /// Get all orders for admin
  static Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await ApiService.get(
        AppConstants.adminOrdersEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch orders');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
// print('Get orders error: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get order by ID
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response =
          await ApiService.get('${AppConstants.ordersEndpoint}/$orderId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch order');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch order');
      }
    } catch (e) {
// print('Get order error: $e');
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Update order status
  static Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String fulfillmentStatus, {
    String? merchantNotes,
  }) async {
    try {
      final data = {
        'fulfillmentStatus': fulfillmentStatus,
        if (merchantNotes != null) 'merchantNotes': merchantNotes,
      };

      final response = await ApiService.put(
        '${AppConstants.ordersEndpoint}/$orderId/status',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return responseData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update order');
        }
      } else {
        final responseData = response.data;
        throw Exception(responseData['message'] ?? 'Failed to update order');
      }
    } catch (e) {
// print('Update order status error: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  /// Cancel order
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      final response = await ApiService.put(
        '${AppConstants.ordersEndpoint}/$orderId',
        data: {
          'fulfillmentStatus': 'cancelled',
          'merchantNotes': reason,
        },
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
// print('Cancel order error: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  // DASHBOARD ANALYTICS

  /// Get dashboard statistics
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // For now, return mock data since backend endpoints don't exist yet
      // TODO: Implement backend endpoints: /admin/dashboard

      // Try to get basic stats from orders
      final orders = await getAllOrders();

      final totalOrders = orders.length;
      final pendingOrders =
          orders.where((o) => o['fulfillmentStatus'] == 'pending').length;
      final totalRevenue = orders.fold<double>(
          0.0, (sum, order) => sum + (order['total'] ?? 0.0));

      return {
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'totalCustomers': 0, // TODO: Get from users endpoint
        'pendingOrders': pendingOrders,
        'todayOrders': 0, // TODO: Filter by date
        'todayRevenue': 0.0, // TODO: Filter by date
        'recentOrders': orders.take(5).toList(),
        'popularCakes': <Map<String, dynamic>>[],
      };
    } catch (e) {
// print('Get dashboard stats error: $e');
      // Return empty stats on error
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'totalCustomers': 0,
        'pendingOrders': 0,
        'todayOrders': 0,
        'todayRevenue': 0.0,
        'recentOrders': <Map<String, dynamic>>[],
        'popularCakes': <Map<String, dynamic>>[],
      };
    }
  }

  /// Get revenue analytics
  static Future<Map<String, dynamic>> getRevenueAnalytics({
    String period = 'month', // 'week', 'month', 'year'
  }) async {
    try {
      // TODO: Implement backend endpoint: /admin/analytics/revenue

      // For now, return mock chart data
      return {
        'chartData': [
          {'date': '2024-01', 'revenue': 15000},
          {'date': '2024-02', 'revenue': 18000},
          {'date': '2024-03', 'revenue': 22000},
          {'date': '2024-04', 'revenue': 19000},
          {'date': '2024-05', 'revenue': 25000},
          {'date': '2024-06', 'revenue': 28000},
        ],
        'totalRevenue': 127000.0,
        'growth': 12.5,
      };
    } catch (e) {
// print('Get revenue analytics error: $e');
      return {'chartData': [], 'totalRevenue': 0.0, 'growth': 0.0};
    }
  }

  // USER MANAGEMENT

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers({
    int? page,
    int? limit,
    String? search,
  }) async {
    try {
      // TODO: Implement backend endpoint: /admin/users

      // For now, return empty list
// print('Get users error: Backend endpoint not implemented');
      return [];
    } catch (e) {
// print('Get users error: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Update user role
  static Future<void> updateUserRole(String userId, String role) async {
    try {
      // TODO: Implement backend endpoint: /admin/users/:id/role

// print('Update user role error: Backend endpoint not implemented');
      throw Exception('Backend endpoint not implemented');
    } catch (e) {
// print('Update user role error: $e');
      throw Exception('Failed to update user role: $e');
    }
  }
}
