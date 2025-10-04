import 'package:flutter/material.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/cart_service.dart';
import 'shared/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/catalog/presentation/screens/home_screen.dart';
import 'features/catalog/presentation/screens/cake_detail_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/addresses_screen.dart';
import 'features/profile/presentation/screens/payment_methods_screen.dart';
import 'features/profile/presentation/screens/help_center_screen.dart';
import 'features/profile/presentation/screens/notifications_settings_screen.dart';
import 'features/profile/presentation/screens/favorites_screen.dart';
import 'features/profile/presentation/screens/reviews_screen.dart';
import 'features/profile/presentation/screens/contact_us_screen.dart';
import 'features/profile/presentation/screens/about_screen.dart';
import 'features/profile/presentation/screens/privacy_security_screen.dart';
import 'features/profile/presentation/screens/language_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/add_cake_screen.dart';
import 'features/admin/presentation/screens/manage_orders_screen.dart';
import 'features/training/presentation/screens/training_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.init();
  await ApiService.init();

  // Load cart on startup
  await CartService.loadCart();

  runApp(const CakeShopApp());
}

class CakeShopApp extends StatelessWidget {
  const CakeShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Denzel's Cakes",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/search': (context) => const SearchScreen(),
        '/training': (context) => const TrainingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/addresses': (context) => const AddressesScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/help-center': (context) => const HelpCenterScreen(),
        '/notifications-settings': (context) =>
            const NotificationsSettingsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/reviews': (context) => const ReviewsScreen(),
        '/contact-us': (context) => const ContactUsScreen(),
        '/about': (context) => const AboutScreen(),
        '/privacy-security': (context) => const PrivacySecurityScreen(),
        '/language': (context) => const LanguageScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin/add-cake': (context) => const AddCakeScreen(),
        '/admin/orders': (context) => const ManageOrdersScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like cake detail
        if (settings.name?.startsWith('/cake/') == true) {
          final cakeId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => CakeDetailScreen(cakeId: cakeId),
          );
        }
        return null;
      },
    );
  }
}
