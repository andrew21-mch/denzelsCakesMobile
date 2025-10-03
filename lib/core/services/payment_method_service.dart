import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/payment_method_model.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

class PaymentMethodService {
  /// Get user's saved payment methods
  static Future<List<PaymentMethodModel>> getUserPaymentMethods() async {
    final List<Map<String, dynamic>> allMethods = [];

    try {
      // Load payment methods from backend first
      final response = await ApiService.get('/payments/user-methods');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> methods = response.data['data'] ?? [];
        allMethods.addAll(methods.cast<Map<String, dynamic>>());
// print('DEBUG: Loaded ${allMethods.length} payment methods from backend');
      } else {
// print('DEBUG: Backend returned: ${response.data}');
      }
    } catch (e) {
// print('DEBUG: Error loading payment methods from backend: $e');
    }

    // If no backend methods, check local storage as fallback
    if (allMethods.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userMethodsJson = prefs.getString('user_payment_methods');
        if (userMethodsJson != null) {
          final List<dynamic> userMethods = jsonDecode(userMethodsJson);
          allMethods.addAll(userMethods.cast<Map<String, dynamic>>());
// print('DEBUG: Loaded ${allMethods.length} payment methods from local storage');
        }
      } catch (e) {
// print('DEBUG: Error loading user payment methods from storage: $e');
      }
    }

    // If still no methods, show demo methods
    if (allMethods.isEmpty) {
      final demoMethods = await _getDemoPaymentMethods();
      allMethods.addAll(demoMethods);
// print('DEBUG: Using ${allMethods.length} demo payment methods');
    }

    // Convert to PaymentMethodModel objects
    try {
      return allMethods
          .map((method) => PaymentMethodModel.fromJson(method))
          .toList();
    } catch (e) {
// print('DEBUG: Error converting payment methods: $e');
      return [];
    }
  }

  /// Add a new payment method
  static Future<PaymentMethodModel> addPaymentMethod({
    required String type,
    required Map<String, dynamic> details,
  }) async {
    try {
      final response = await ApiService.post(
        '/payments/user-methods',
        data: {
          'type': type,
          ...details,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
// print('DEBUG: Payment method added successfully to backend');
        return PaymentMethodModel.fromJson(response.data['data']);
      } else {
// print('DEBUG: Failed to add payment method to backend: ${response.data}');
        throw Exception('Failed to add payment method');
      }
    } catch (e) {
// print('DEBUG: Error adding payment method to backend: $e');
      throw Exception('Failed to add payment method');
    }
  }

  /// Update a payment method (e.g., set as default)
  static Future<bool> updatePaymentMethod(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await ApiService.put(
        '/payments/user-methods/$id',
        data: updates,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
// print('DEBUG: Payment method updated successfully in backend');
        return true;
      } else {
// print('DEBUG: Failed to update payment method in backend: ${response.data}');
        return false;
      }
    } catch (e) {
// print('DEBUG: Error updating payment method in backend: $e');
      return false;
    }
  }

  /// Delete a payment method
  static Future<bool> deletePaymentMethod(String id) async {
    try {
      final response = await ApiService.delete('/payments/user-methods/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
// print('DEBUG: Payment method deleted successfully from backend');
        return true;
      } else {
// print('DEBUG: Failed to delete payment method from backend: ${response.data}');
        return false;
      }
    } catch (e) {
// print('DEBUG: Error deleting payment method from backend: $e');
      return false;
    }
  }

  /// Get demo payment methods for testing
  static Future<List<Map<String, dynamic>>> _getDemoPaymentMethods() async {
    final List<Map<String, dynamic>> demoMethods = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final showDemoMethods =
          prefs.getBool('show_demo_payment_methods') ?? true;
      final cardDeleted = prefs.getBool('demo_card_deleted') ?? false;
      final momoDeleted = prefs.getBool('demo_momo_deleted') ?? false;

      if (showDemoMethods) {
        // Get current user for demo data
        User? currentUser;
        try {
          final userData = await StorageService.getUserData();
          if (userData != null) {
            currentUser = User.fromJson(userData);
          }
        } catch (e) {
// print('DEBUG: Error loading user data: $e');
        }

        // Add demo card if not deleted
        if (!cardDeleted) {
          demoMethods.add({
            'id': 'demo_card_1',
            'type': 'card',
            'cardType': 'visa',
            'lastFour': '4242',
            'expiryMonth': '12',
            'expiryYear': '25',
            'holderName': currentUser?.name ?? 'User',
            'isDefault': true,
            'isDemo': true,
          });
        }

        // Add demo mobile money if not deleted
        if (!momoDeleted) {
          demoMethods.add({
            'id': 'demo_momo_1',
            'type': 'mobile_money',
            'provider': 'MTN Mobile Money',
            'phoneNumber': '+237 6XX XXX XXX',
            'isDefault': cardDeleted, // Make it default if card is deleted
            'isDemo': true,
          });
        }

        // Add Orange Money demo method if both others exist
        if (!cardDeleted && !momoDeleted) {
          demoMethods.add({
            'id': 'demo_orange_1',
            'type': 'mobile_money',
            'provider': 'Orange Money',
            'phoneNumber': '+237 6YY YYY YYY',
            'isDefault': false,
            'isDemo': true,
          });
        }
      }
    } catch (e) {
// print('DEBUG: Error loading demo payment methods: $e');
    }

    return demoMethods;
  }

  /// Set a payment method as default
  static Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      final response = await ApiService.put(
        '/payments/user-methods/$methodId',
        data: {'isDefault': true},
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to set default payment method');
      }
// print('DEBUG: Payment method set as default successfully in backend');
    } on DioException catch (e) {
// print('DEBUG: Error setting default payment method: $e');
      throw Exception(e.response?.data['message'] ??
          'Failed to set default payment method');
    } catch (e) {
// print('DEBUG: Error setting default payment method: $e');
      throw Exception('Failed to set default payment method');
    }
  }
}
