import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AdminApiService {
  // CAKE MANAGEMENT

  /// Upload image to server and get URL
  static Future<String> uploadImage(File imageFile) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token == null || token.isEmpty) {
        throw ApiException('Sign in again, then save the cake.');
      }

      final filename = _imageFilename(imageFile.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: filename,
        ),
        'folder': 'cakes',
      });

      // Leave Content-Type unset so the upload keeps its boundary.
      // Setting multipart/form-data here was sending the photo with no token.
      final response = await ApiService.post(
        AppConstants.mediaUploadEndpoint,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
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
      throw ApiException(ApiService.readableError(e));
    }
  }

  static String _imageFilename(String path) {
    final name = path.split(Platform.pathSeparator).last;
    final lower = name.toLowerCase();
    const endings = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    if (endings.any(lower.endsWith)) return name;
    return '$name.jpg';
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
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update existing cake
  static Future<Map<String, dynamic>> updateCake(
      String cakeId, Map<String, dynamic> cakeData) async {
    try {
      final response = await ApiService.put(
        '${AppConstants.cakesEndpoint}/$cakeId',
        data: cakeData,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        final data = response.data;
        if (data['errors'] != null) {
          throw Exception(data['errors'].join(', '));
        }
        throw Exception(data['message'] ?? 'Failed to update cake');
      }
    } catch (e) {
// print('Update cake error: $e');
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
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
        '${AppConstants.ordersEndpoint}/$orderId',
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
      throw ApiException(ApiService.readableError(e));
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
      throw ApiException(ApiService.readableError(e));
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
      final response = await ApiService.get(AppConstants.usersEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch users');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
// print('Get users error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update user role
  static Future<void> updateUserRole(String userId, String role) async {
    try {
      final response = await ApiService.put(
        '${AppConstants.usersEndpoint}/$userId/role',
        data: {'role': role},
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update user role');
      }
    } catch (e) {
// print('Update user role error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  // SETTINGS MANAGEMENT

  /// Get business information
  static Future<Map<String, dynamic>> getBusinessInfo() async {
    try {
      final response = await ApiService.get(AppConstants.businessInfoEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch business info');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch business info');
      }
    } catch (e) {
// print('Get business info error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update business information
  static Future<void> updateBusinessInfo(
      Map<String, dynamic> businessData) async {
    try {
      final response = await ApiService.put(
        AppConstants.businessInfoEndpoint,
        data: businessData,
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update business info');
      }
    } catch (e) {
// print('Update business info error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get payment methods
  static Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response =
          await ApiService.get(AppConstants.paymentMethodsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch payment methods');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch payment methods');
      }
    } catch (e) {
// print('Get payment methods error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update payment methods
  static Future<void> updatePaymentMethods(
      Map<String, dynamic> paymentData) async {
    try {
      final response = await ApiService.put(
        AppConstants.paymentMethodsEndpoint,
        data: paymentData,
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update payment methods');
      }
    } catch (e) {
// print('Update payment methods error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get delivery settings
  static Future<Map<String, dynamic>> getDeliverySettings() async {
    try {
      final response =
          await ApiService.get(AppConstants.deliverySettingsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch delivery settings');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch delivery settings');
      }
    } catch (e) {
// print('Get delivery settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update delivery settings
  static Future<void> updateDeliverySettings(
      Map<String, dynamic> deliveryData) async {
    try {
      final response = await ApiService.put(
        AppConstants.deliverySettingsEndpoint,
        data: deliveryData,
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(
            data['message'] ?? 'Failed to update delivery settings');
      }
    } catch (e) {
// print('Update delivery settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get user roles and permissions
  static Future<List<Map<String, dynamic>>> getUserRoles() async {
    try {
      final response = await ApiService.get(AppConstants.usersEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch user roles');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch user roles');
      }
    } catch (e) {
// print('Get user roles error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update user roles
  static Future<void> updateUserRoles(
      List<Map<String, dynamic>> rolesData) async {
    try {
      final response = await ApiService.put(
        AppConstants.usersEndpoint,
        data: {'roles': rolesData},
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update user roles');
      }
    } catch (e) {
// print('Update user roles error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get notification settings
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response =
          await ApiService.get(AppConstants.notificationSettingsEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch notification settings');
        }
      } else {
        final data = response.data;
        throw Exception(
            data['message'] ?? 'Failed to fetch notification settings');
      }
    } catch (e) {
// print('Get notification settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get notification history
  static Future<List<Map<String, dynamic>>> getNotificationHistory({
    int limit = 50,
    int offset = 0,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await ApiService.get(
        '${AppConstants.notificationSettingsEndpoint}/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data'] ?? []);
        } else {
          throw Exception(
              data['message'] ?? 'Failed to fetch notification history');
        }
      } else {
        final data = response.data;
        throw Exception(
            data['message'] ?? 'Failed to fetch notification history');
      }
    } catch (e) {
// print('Get notification history error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  static Future<void> updateNotificationSettings(
      Map<String, dynamic> settings) async {
    try {
      final response = await ApiService.put(
        AppConstants.notificationSettingsEndpoint,
        data: settings,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return;
        } else {
          throw Exception(
              data['message'] ?? 'Failed to update notification settings');
        }
      } else {
        final data = response.data;
        throw Exception(
            data['message'] ?? 'Failed to update notification settings');
      }
    } catch (e) {
// print('Update notification settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Send test notification
  static Future<void> sendTestNotification(
      {String type = 'systemAlert'}) async {
    try {
      final response = await ApiService.post(
        '${AppConstants.notificationSettingsEndpoint}/test',
        data: {
          'type': type,
          'channel': type, // Send the channel type
        },
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to send test notification');
      }
    } catch (e) {
// print('Send test notification error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await ApiService.delete(
        '${AppConstants.notificationSettingsEndpoint}/$notificationId',
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to delete notification');
      }
    } catch (e) {
// print('Delete notification error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get backup settings
  static Future<Map<String, dynamic>> getBackupSettings() async {
    try {
      final response = await ApiService.get(AppConstants.backupEndpoint);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch backup settings');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch backup settings');
      }
    } catch (e) {
// print('Get backup settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update backup settings
  static Future<void> updateBackupSettings(
      Map<String, dynamic> backupData) async {
    try {
      final response = await ApiService.put(
        AppConstants.backupEndpoint,
        data: backupData,
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update backup settings');
      }
    } catch (e) {
// print('Update backup settings error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Trigger backup
  static Future<void> triggerBackup() async {
    try {
      final response =
          await ApiService.post('${AppConstants.backupEndpoint}/trigger');

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to trigger backup');
      }
    } catch (e) {
// print('Trigger backup error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Export data
  static Future<Map<String, dynamic>> exportData(String dataType) async {
    try {
      final response = await ApiService.post(
        AppConstants.exportEndpoint,
        data: {'type': dataType},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to export data');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to export data');
      }
    } catch (e) {
// print('Export data error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Generate custom report
  static Future<Map<String, dynamic>> generateReport(
      Map<String, dynamic> reportConfig) async {
    try {
      final response = await ApiService.post(
        AppConstants.reportsEndpoint,
        data: reportConfig,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to generate report');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to generate report');
      }
    } catch (e) {
// print('Generate report error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  // CUSTOMER MANAGEMENT

  /// Get all customers with pagination and filtering
  static Future<Map<String, dynamic>> getAllCustomers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    try {
      Map<String, dynamic> params = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      if (status != null && status != 'all') {
        params['status'] = status;
      }

      final response = await ApiService.get(
        '/auth/admin/customers',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch customers');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch customers');
      }
    } catch (e) {
// print('Get customers error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Get customer statistics
  static Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      final response = await ApiService.get('/auth/admin/customers/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch customer stats');
        }
      } else {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to fetch customer stats');
      }
    } catch (e) {
// print('Get customer stats error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Update customer status
  static Future<void> updateCustomerStatus(
      String customerId, String status) async {
    try {
      final response = await ApiService.put(
        '/auth/admin/customers/$customerId/status',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to update customer status');
      }
    } catch (e) {
// print('Update customer status error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }

  /// Delete customer
  static Future<void> deleteCustomer(String customerId) async {
    try {
      final response =
          await ApiService.delete('/auth/admin/customers/$customerId');

      if (response.statusCode != 200) {
        final data = response.data;
        throw Exception(data['message'] ?? 'Failed to delete customer');
      }
    } catch (e) {
// print('Delete customer error: $e');
      throw ApiException(ApiService.readableError(e));
    }
  }
}
