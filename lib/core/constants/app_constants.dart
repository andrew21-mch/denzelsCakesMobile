class AppConstants {
  // API Configuration
  static const String baseUrl =
      'http://10.208.227.47:3000/api/v1'; // Updated IP address
  // static const String baseUrl = 'http://192.168.0.164:3000/api/v1'; // Updated IP address
  static const String apiVersion = 'v1';

  // Stripe Configuration
  static const String stripePublishableKey =
      'pk_test_your_stripe_publishable_key';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String cartDataKey = 'cart_data';

  // App Configuration
  static const String appName = "Denzel's Cakes";
  static const String appVersion = '1.0.0';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage =
      'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error occurred. Please try again later.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
  static const String validationErrorMessage =
      'Please check your input and try again.';

  // Success Messages
  static const String loginSuccessMessage = 'Welcome back!';
  static const String registerSuccessMessage = 'Account created successfully!';
  static const String orderSuccessMessage = 'Order placed successfully!';
  static const String paymentSuccessMessage = 'Payment completed successfully!';

  // Currency
  static const String defaultCurrency = 'FCFA';
  static const String currencySymbol = 'XAF';

  // Order Status
  static const Map<String, String> orderStatusLabels = {
    'pending': 'Pending',
    'accepted': 'Accepted',
    'in_progress': 'In Progress',
    'ready': 'Ready',
    'out_for_delivery': 'Out for Delivery',
    'delivered': 'Delivered',
    'cancelled': 'Cancelled',
    'refunded': 'Refunded',
  };

  // Payment Methods
  static const Map<String, String> paymentMethodLabels = {
    'card': 'Credit/Debit Card',
    'momo': 'Mobile Money',
    'cash': 'Cash on Delivery',
  };

  // Delivery Types
  static const Map<String, String> deliveryTypeLabels = {
    'pickup': 'Store Pickup',
    'delivery': 'Home Delivery',
  };

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String loginEndpoint = '$authEndpoint/login';
  static const String registerEndpoint = '$authEndpoint/register';
  static const String refreshEndpoint = '$authEndpoint/refresh';

  static const String cakesEndpoint = '/cakes';
  static const String ordersEndpoint = '/orders';
  static const String mediaEndpoint = '/media';
  static const String paymentsEndpoint = '/payments';

  // Settings Endpoints
  static const String settingsEndpoint = '/settings';
  static const String businessInfoEndpoint = '$settingsEndpoint/business';
  static const String paymentMethodsEndpoint =
      '$settingsEndpoint/payment-methods';
  static const String deliverySettingsEndpoint = '$settingsEndpoint/delivery';
  static const String usersEndpoint = '$settingsEndpoint/users';
  static const String notificationSettingsEndpoint =
      '$settingsEndpoint/notifications';
  static const String backupEndpoint = '$settingsEndpoint/backup';
  static const String exportEndpoint = '$settingsEndpoint/export';
  static const String reportsEndpoint = '$settingsEndpoint/reports';

  // Admin Endpoints
  static const String adminOrdersEndpoint = '$ordersEndpoint/admin/all';
  static const String adminOrderUpdateEndpoint =
      ordersEndpoint; // + /{id}/status
  static const String mediaUploadEndpoint = '$mediaEndpoint/upload';

  // Future Admin Endpoints (to be implemented in backend)
  static const String adminDashboardEndpoint = '/admin/dashboard';
  static const String adminAnalyticsEndpoint = '/admin/analytics';
  static const String adminUsersEndpoint = '/admin/users';

  // Reviews Endpoints
  static const String reviewsEndpoint = '/reviews';
}
