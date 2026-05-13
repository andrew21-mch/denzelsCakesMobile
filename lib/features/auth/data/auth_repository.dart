import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/user_model.dart';

class AuthRepository {
  // Login with email or phone
  static Future<AuthResponse> login({
    required String identifier, // Can be email or phone
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data['data']);

        // Store tokens and user data
        await StorageService.setAccessToken(authResponse.tokens.accessToken);
        await StorageService.setRefreshToken(authResponse.tokens.refreshToken);
        await StorageService.setUserData(authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Login failed');
    }
  }

  // Register with either email or phone (at least one required)
  static Future<AuthResponse> register({
    required String name,
    String? email,
    required String password,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'password': password,
      };

      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }

      final response = await ApiService.post(
        '/auth/register',
        data: data,
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data['data']);

        // Store tokens and user data
        await StorageService.setAccessToken(authResponse.tokens.accessToken);
        await StorageService.setRefreshToken(authResponse.tokens.refreshToken);
        await StorageService.setUserData(authResponse.user.toJson());

        return authResponse;
      } else {
        throw Exception('Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Registration failed');
    }
  }

  // Get current user profile
  static Future<User> getProfile() async {
    try {
      final response = await ApiService.get('/auth/profile');

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['data']);

        // Update stored user data
        await StorageService.setUserData(user.toJson());

        return user;
      } else {
        throw Exception('Failed to get profile');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to get profile');
    }
  }

  // Update profile
  static Future<User> updateProfile({
    String? name,
    String? phone,
    List<Address>? addresses,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (addresses != null) {
        data['addresses'] = addresses.map((addr) => addr.toJson()).toList();
      }

      final response = await ApiService.put('/auth/profile', data: data);

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data['data']);

        // Update stored user data
        await StorageService.setUserData(user.toJson());

        return user;
      } else {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to update profile');
    }
  }

  // Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Failed to change password');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Try to call logout endpoint (optional, since we're clearing local data anyway)
      try {
        await ApiService.post('/auth/logout');
      } catch (e) {
        // Ignore logout endpoint errors
      }

      // Clear all local data
      await StorageService.logout();
    } catch (e) {
      // Even if API call fails, clear local data
      await StorageService.logout();
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await StorageService.getAccessToken();
    return accessToken != null;
  }

  // Get current user from storage
  static Future<User?> getCurrentUser() async {
    final userData = await StorageService.getUserData();
    if (userData != null) {
      try {
        return User.fromJson(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Refresh tokens (handled automatically by ApiService interceptor)
  static Future<AuthTokens> refreshTokens() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await ApiService.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final tokens = AuthTokens.fromJson(response.data['data']);

        // Store new tokens
        await StorageService.setAccessToken(tokens.accessToken);
        await StorageService.setRefreshToken(tokens.refreshToken);

        return tokens;
      } else {
        throw Exception('Token refresh failed');
      }
    } on DioException catch (e) {
      // Clear tokens on refresh failure
      await StorageService.clearTokens();
      throw Exception(e.error ?? 'Token refresh failed');
    }
  }
}
