import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/catalog/presentation/screens/home_screen.dart';
import '../../features/catalog/presentation/screens/cake_detail_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/training/presentation/screens/training_screen.dart';
import '../../core/services/storage_service.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String cakeDetail = '/cake/:id';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String training = '/training';
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      // Check if user is authenticated
      final accessToken = await StorageService.getAccessToken();
      final isAuthenticated = accessToken != null;

      // Define public routes that don't require authentication
      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.home,
        AppRoutes.search,
        AppRoutes.training,
      ];

      // Check if current route is public
      final isPublicRoute = publicRoutes.any((route) =>
          state.matchedLocation.startsWith(route.replaceAll(':id', '')));

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      // If authenticated and on login/register, redirect to home
      if (isAuthenticated &&
          (state.matchedLocation == AppRoutes.login ||
              state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.cakeDetail,
        name: 'cakeDetail',
        builder: (context, state) {
          final cakeId = state.pathParameters['id']!;
          return CakeDetailScreen(cakeId: cakeId);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: query);
        },
      ),

      // Cart and checkout routes
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Profile route
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Orders routes
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),

      // Training routes
      GoRoute(
        path: AppRoutes.training,
        name: 'training',
        builder: (context, state) => const TrainingScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation helper extension
extension AppRouterExtension on GoRouter {
  void pushLogin() => push(AppRoutes.login);
  void pushRegister() => push(AppRoutes.register);
  void goHome() => go(AppRoutes.home);
  void pushCakeDetail(String cakeId) => push('/cake/$cakeId');
  void pushSearch({String? query}) {
    final uri = Uri(
        path: AppRoutes.search,
        queryParameters: query != null ? {'q': query} : null);
    push(uri.toString());
  }

  void pushCart() => push(AppRoutes.cart);
  void pushCheckout() => push(AppRoutes.checkout);
  void pushProfile() => push(AppRoutes.profile);
  void pushOrders() => push(AppRoutes.orders);
  void pushOrderDetail(String orderId) => push('/orders/$orderId');
  void pushTraining() => push(AppRoutes.training);
}
