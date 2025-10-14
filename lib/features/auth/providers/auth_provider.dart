import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user_model.dart';
import '../data/auth_repository.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isLoggedIn = await AuthRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthRepository.getCurrentUser();
        if (user != null) {
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
          return;
        }
      }

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Login
  Future<void> login({
    required String identifier, // Can be email or phone
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await AuthRepository.login(
        identifier: identifier,
        password: password,
      );

      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Register
  Future<void> register({
    required String name,
    String? email,
    required String password,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final authResponse = await AuthRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? name,
    String? phone,
    List<Address>? addresses,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedUser = await AuthRepository.updateProfile(
        name: name,
        phone: phone,
        addresses: addresses,
      );

      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await AuthRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await AuthRepository.logout();

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      // Even if logout fails, clear the state
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;

    try {
      final user = await AuthRepository.getProfile();
      state = state.copyWith(user: user);
    } catch (e) {
      // Handle error silently for refresh
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
