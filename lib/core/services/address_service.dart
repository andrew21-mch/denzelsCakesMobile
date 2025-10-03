import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AddressService {
  /// Get user's addresses from their profile
  static Future<List<Address>> getUserAddresses() async {
    try {
      final response = await ApiService.get('/auth/profile');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'];
        final addressesData = userData['addresses'] as List? ?? [];

        return addressesData
            .map((addressJson) => Address.fromJson(addressJson))
            .toList();
      }

      throw Exception('Failed to load addresses');
    } on DioException catch (e) {
// print('DEBUG: Error getting user addresses: $e');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to load addresses');
    } catch (e) {
// print('DEBUG: Error getting user addresses: $e');
      throw Exception('Failed to load addresses');
    }
  }

  /// Add a new address to user's profile
  static Future<Address> addAddress(Address address) async {
    try {
      final response = await ApiService.post(
        '/auth/addresses',
        data: address.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'];
        final addressesData = userData['addresses'] as List? ?? [];

        // Return the newly added address (last one)
        return Address.fromJson(addressesData.last);
      }

      throw Exception('Failed to add address');
    } on DioException catch (e) {
// print('DEBUG: Error adding address: $e');
      throw Exception(e.response?.data['message'] ?? 'Failed to add address');
    } catch (e) {
// print('DEBUG: Error adding address: $e');
      throw Exception('Failed to add address');
    }
  }

  /// Update an existing address
  static Future<Address> updateAddress(
      String addressId, Address address) async {
    try {
      final response = await ApiService.put(
        '/auth/addresses/$addressId',
        data: address.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['data'];
        final addressesData = userData['addresses'] as List? ?? [];

        // Find and return the updated address
        final updatedAddress = addressesData.firstWhere(
          (addr) => addr['_id'] == addressId,
          orElse: () => addressesData.first,
        );

        return Address.fromJson(updatedAddress);
      }

      throw Exception('Failed to update address');
    } on DioException catch (e) {
// print('DEBUG: Error updating address: $e');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to update address');
    } catch (e) {
// print('DEBUG: Error updating address: $e');
      throw Exception('Failed to update address');
    }
  }

  /// Delete an address from user's profile
  static Future<void> deleteAddress(String addressId) async {
    try {
      final response = await ApiService.delete('/auth/addresses/$addressId');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to delete address');
      }
    } on DioException catch (e) {
// print('DEBUG: Error deleting address: $e');
      throw Exception(
          e.response?.data['message'] ?? 'Failed to delete address');
    } catch (e) {
// print('DEBUG: Error deleting address: $e');
      throw Exception('Failed to delete address');
    }
  }

  /// Set an address as default
  static Future<void> setDefaultAddress(String addressId) async {
    try {
      // This would typically be handled by updating the address with isDefault: true
      // and the backend should automatically set other addresses to isDefault: false
      final address = Address(
        id: addressId,
        type: '', // Will be ignored in update
        street: '', // Will be ignored in update
        city: '', // Will be ignored in update
        state: '', // Will be ignored in update
        zipCode: '', // Will be ignored in update
        country: '', // Will be ignored in update
        isDefault: true,
      );

      await updateAddress(addressId, address);
    } catch (e) {
// print('DEBUG: Error setting default address: $e');
      throw Exception('Failed to set default address');
    }
  }
}
