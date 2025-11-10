import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/cart_service.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/locale_service.dart';
import 'features/profile/presentation/screens/language_screen.dart' as lang_screen;
import 'shared/theme/app_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/catalog/presentation/screens/home_screen.dart';
import 'features/catalog/presentation/screens/cake_detail_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/orders/presentation/screens/orders_screen.dart';
import 'features/orders/presentation/screens/custom_order_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/addresses_screen.dart';
import 'features/profile/presentation/screens/add_address_with_map_screen.dart';
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

  // Initialize services first
  await StorageService.init();
  await ApiService.init();

  // Initialize Firebase with proper error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize messaging service
    await FirebaseMessagingService.initialize();
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }

  // Load cart on startup
  await CartService.loadCart();

  runApp(const CakeShopApp());
}

class CakeShopApp extends StatefulWidget {
  const CakeShopApp({super.key});

  @override
  State<CakeShopApp> createState() => _CakeShopAppState();
}

class _CakeShopAppState extends State<CakeShopApp> {
  Locale _locale = LocaleService.defaultLocale;
  bool _isLocaleLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    // Register locale updater callback
    lang_screen.LocaleUpdater.updateLocaleCallback = updateLocale;
  }

  @override
  void dispose() {
    lang_screen.LocaleUpdater.updateLocaleCallback = null;
    super.dispose();
  }

  Future<void> _loadLocale() async {
    final locale = await LocaleService.getLocale();
    // Ensure AppLocalizations delegate is loaded for the locale
    await AppLocalizations.delegate.load(locale);
    setState(() {
      _locale = locale;
      _isLocaleLoaded = true;
    });
  }

  void updateLocale(Locale newLocale) async {
    await LocaleService.setLocale(newLocale);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always provide localizations, even during loading
    final localizationsDelegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    if (!_isLocaleLoaded) {
      return MaterialApp(
        title: "Denzel's Cakes",
        locale: LocaleService.defaultLocale,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: LocaleService.supportedLocales,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: "Denzel's Cakes",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      locale: _locale,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: LocaleService.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        // If locale is null, use default
        if (locale == null) {
          return LocaleService.defaultLocale;
        }
        // Check for exact match
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // Check for language match
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        // Return default
        return LocaleService.defaultLocale;
      },
      home: const SplashScreen(),
      // Don't use initialRoute when home is set - it can cause route generation issues
      // Note: '/' route is not needed since we use 'home' property
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/custom-order': (context) => const CustomOrderScreen(),
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
        try {
          // Handle dynamic routes like cake detail
          if (settings.name != null && settings.name!.startsWith('/cake/')) {
            final parts = settings.name!.split('/');
            if (parts.length >= 3) {
              final cakeId = parts.last;
              return MaterialPageRoute(
                builder: (context) => CakeDetailScreen(cakeId: cakeId),
                settings: settings,
              );
            }
          }
          // Handle add address route
          if (settings.name == '/add-address') {
            return MaterialPageRoute(
              builder: (context) => AddAddressWithMapScreen(
                onSave: (address) {
                  Navigator.of(context).pop(address);
                },
              ),
              settings: settings,
            );
          }
        } catch (e) {
          debugPrint('Error generating route: $e');
        }
        return null;
      },
      onUnknownRoute: (settings) {
        // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}

