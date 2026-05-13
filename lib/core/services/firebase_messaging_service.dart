import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final Logger _logger = Logger();
  static String? _fcmToken;
  static FlutterLocalNotificationsPlugin? _localNotifications;

  /// Initialize Firebase messaging
  static Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i('User granted permission: ${settings.authorizationStatus}');

      // Try to get FCM token with timeout
      await _getFCMTokenWithTimeout();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      _logger.e('Failed to initialize Firebase messaging: $e');
      _logger.i('App will continue without push notifications');
    }
  }

  /// Initialize local notifications plugin
  static Future<void> _initializeLocalNotifications() async {
    try {
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _localNotifications!.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _logger.i('Local notification tapped: ${response.id}');
          // Handle notification tap
        },
      );

      // Create notification channel for Android
      await _createNotificationChannel();

      _logger.i('Local notifications initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize local notifications: $e');
    }
  }

  /// Create notification channel for Android
  static Future<void> _createNotificationChannel() async {
    if (_localNotifications == null) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'denzels_cakes_notifications', // id
      'Denzel\'s Cakes Notifications', // name
      description: 'Notifications for orders, updates, and messages',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Get FCM token with timeout
  static Future<void> _getFCMTokenWithTimeout() async {
    try {
      _logger.i('Attempting to get FCM token...');

      // Try to get token with 10 second timeout
      _fcmToken = await _messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.w('FCM token retrieval timed out');
          return null;
        },
      );

      if (_fcmToken != null) {
        _logger.i('FCM Token obtained successfully');
        await _registerFCMToken(_fcmToken!);
      } else {
        _logger
            .w('FCM Token is null - Google Play Services may not be available');
      }
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
      _logger.i('App will continue without push notifications');
    }
  }

  /// Get FCM token and register with backend
  static Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        _logger.i('FCM Token: $_fcmToken');
        await _registerFCMToken(_fcmToken!);
      } else {
        _logger.w('FCM Token is null');
      }
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
    }
  }

  /// Register FCM token with backend
  static Future<void> _registerFCMToken(String token) async {
    try {
      _logger.i('Attempting to register FCM token with backend...');
      _logger.i('Token: ${token.substring(0, 20)}...');

      final response = await ApiService.post(
        '${AppConstants.authEndpoint}/fcm-token',
        data: {'fcmToken': token},
      );

      _logger.i('Backend response status: ${response.statusCode}');
      _logger.i('Backend response data: ${response.data}');

      if (response.statusCode == 200) {
        _logger.i('✅ FCM token registered successfully with backend');
      } else {
        _logger.e('❌ Failed to register FCM token: ${response.statusCode}');
        _logger.e('Response: ${response.data}');
      }
    } catch (e) {
      _logger.e('❌ Failed to register FCM token: $e');
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('Received foreground message: ${message.messageId}');
    _logger.i('Title: ${message.notification?.title}');
    _logger.i('Body: ${message.notification?.body}');

    // Show a local notification when app is in foreground
    _showLocalNotification(message);
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    if (_localNotifications == null) {
      _logger.w('Local notifications not initialized');
      return;
    }

    try {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) {
        _logger.w('No notification data in message');
        return;
      }

      _logger.i('Showing local notification: ${notification.title}');

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'denzels_cakes_notifications',
        'Denzel\'s Cakes Notifications',
        channelDescription: 'Notifications for orders, updates, and messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _localNotifications!.show(
        message.hashCode, // Use message hash as ID to avoid duplicates
        notification.title ?? 'Denzel\'s Cakes',
        notification.body ?? '',
        details,
        payload: data.toString(),
      );

      _logger.i('✅ Local notification shown successfully');
    } catch (e) {
      _logger.e('Failed to show local notification: $e');
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    _logger.i('Notification tapped: ${message.messageId}');

    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'newOrder':
          // Navigate to orders screen
          break;
        case 'orderStatus':
          // Navigate to order details
          break;
        case 'paymentReceived':
          // Navigate to payments screen
          break;
        default:
          // Navigate to notifications screen
          break;
      }
    }
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Refresh FCM token
  static Future<void> refreshToken() async {
    await _getFCMToken();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final logger = Logger();
  logger.i('Handling background message: ${message.messageId}');
}
