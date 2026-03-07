import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

/// A widget that listens to Firebase notifications and displays them
/// 
/// Usage:
/// ```dart
/// MaterialApp(
///   home: Scaffold(
///     body: NotificationListener(
///       child: YourHomeScreen(),
///     ),
///   ),
/// )
/// ```
class NotificationListener extends StatefulWidget {
  final Widget child;
  final Function(RemoteMessage)? onNotificationReceived;

  const NotificationListener({
    Key? key,
    required this.child,
    this.onNotificationReceived,
  }) : super(key: key);

  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification received in foreground');
      
      // Call user's callback if provided
      widget.onNotificationReceived?.call(message);
      
      // Show a snackbar or dialog
      _showNotificationDialog(message);
    });
  }

  void _showNotificationDialog(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message.notification?.title ?? 'Notification'),
          content: Text(message.notification?.body ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (message.data.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleNotificationTap(message);
                },
                child: const Text('View'),
              ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final String? screen = message.data['screen'];
    final String? itemId = message.data['item_id'];
    
    print('Navigating to: $screen with item: $itemId');
    
    // Add your navigation logic here
    switch (screen) {
      case 'plant_detail':
        // Navigate to plant detail screen
        break;
      case 'orders':
        // Navigate to orders screen
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A simple notification badge widget that shows if notifications are enabled
/// 
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: AppBar(
///     actions: [
///       NotificationBadge(),
///     ],
///   ),
/// )
/// ```
class NotificationBadge extends StatefulWidget {
  const NotificationBadge({Key? key}) : super(key: key);

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Tooltip(
        message: _notificationsEnabled
            ? 'Notifications enabled'
            : 'Notifications disabled',
        child: Icon(
          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
          color: _notificationsEnabled ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}

/// A sheet widget for managing notification preferences
/// 
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => const NotificationPreferencesSheet(),
/// )
/// ```
class NotificationPreferencesSheet extends StatefulWidget {
  const NotificationPreferencesSheet({Key? key}) : super(key: key);

  @override
  State<NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends State<NotificationPreferencesSheet> {
  late NotificationService _notificationService;
  Map<String, bool> _topicSubscriptions = {};

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Preferences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Subscribe to topics:'),
          CheckboxListTile(
            title: const Text('Plant Care Tips'),
            value: _topicSubscriptions['plant_care_tips'] ?? false,
            onChanged: (value) async {
              setState(() {
                _topicSubscriptions['plant_care_tips'] = value ?? false;
              });
              if (value ?? false) {
                await _notificationService.subscribeToTopic('plant_care_tips');
              } else {
                await _notificationService
                    .unsubscribeFromTopic('plant_care_tips');
              }
            },
          ),
          CheckboxListTile(
            title: const Text('Order Updates'),
            value: _topicSubscriptions['order_updates'] ?? false,
            onChanged: (value) async {
              setState(() {
                _topicSubscriptions['order_updates'] = value ?? false;
              });
              if (value ?? false) {
                await _notificationService.subscribeToTopic('order_updates');
              } else {
                await _notificationService.unsubscribeFromTopic('order_updates');
              }
            },
          ),
          CheckboxListTile(
            title: const Text('New Plant Varieties'),
            value: _topicSubscriptions['new_plants'] ?? false,
            onChanged: (value) async {
              setState(() {
                _topicSubscriptions['new_plants'] = value ?? false;
              });
              if (value ?? false) {
                await _notificationService.subscribeToTopic('new_plants');
              } else {
                await _notificationService.unsubscribeFromTopic('new_plants');
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
