import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final Logger _logger = Logger();
  static String? _fcmToken;

  /// Initialize Firebase messaging
  static Future<void> initialize() async {
    try {
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
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
        _logger.w('FCM Token is null - Google Play Services may not be available');
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
  static void _showLocalNotification(RemoteMessage message) {
    // This will show a notification even when app is in foreground
    _logger.i('Showing local notification: ${message.notification?.title}');
    
    // You can implement local notifications here if needed
    // For now, just log it
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
