import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles Firebase Cloud Messaging (FCM) notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging and request permissions
  Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional notification permission');
      } else {
        print('User denied or has not yet granted notification permission');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');

        // Handle foreground notification display (you can show a dialog/snackbar)
        _handleForegroundNotification(message);
      });

      // Handle notification when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from background notification:');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');

        _handleNotificationNavigation(message);
      });

      // Get initial message if app was terminated
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from terminated state:');
        print('Title: ${initialMessage.notification?.title}');
        print('Body: ${initialMessage.notification?.body}');

        _handleNotificationNavigation(initialMessage);
      }

      // Get and print FCM token
      await _getAndPrintToken();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  /// Get the FCM token for the device
  Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Private helper to get and print token
  Future<void> _getAndPrintToken() async {
    String? token = await getToken();
    if (token != null) {
      // You can send this token to your backend to store for sending notifications
      print('Device token obtained: $token');
    }
  }

  /// Handle foreground notification display
  void _handleForegroundNotification(RemoteMessage message) {
    // You can show a dialog, snackbar, or custom notification widget here
    // For now, just logging the notification
    print('Handling foreground notification: ${message.notification?.title}');
  }

  /// Handle notification routing/navigation
  void _handleNotificationNavigation(RemoteMessage message) {
    // Parse the data payload and navigate accordingly
    final String? screen = message.data['screen'];
    final String? orderId = message.data['order_id'];

    print('Navigating from notification. Screen: $screen, OrderId: $orderId');

    // Add navigation logic here based on notification data
    // Example: if (screen == 'orders') { Navigator.pushNamed(...) }
  }

  /// Subscribe to a topic for broadcast messages
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
