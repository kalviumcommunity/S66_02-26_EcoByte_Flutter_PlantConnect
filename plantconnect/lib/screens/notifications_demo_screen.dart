import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class NotificationsDemoScreen extends StatefulWidget {
  const NotificationsDemoScreen({super.key});

  @override
  State<NotificationsDemoScreen> createState() => _NotificationsDemoScreenState();
}

class _NotificationsDemoScreenState extends State<NotificationsDemoScreen> {
  late NotificationService _notificationService;
  String? _fcmToken;
  bool _notificationsEnabled = false;
  final List<String> _topics = [
    'plant_care_tips',
    'order_updates',
    'new_plants',
  ];
  final Map<String, bool> _subscribedTopics = {
    'plant_care_tips': false,
    'order_updates': false,
    'new_plants': false,
  };
  List<String> _receivedNotifications = [];

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadFCMToken();
    _checkNotificationStatus();
    _setupNotificationListeners();
  }

  Future<void> _loadFCMToken() async {
    final token = await _notificationService.getToken();
    setState(() {
      _fcmToken = token;
    });
  }

  Future<void> _checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    setState(() {
      _notificationsEnabled =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
    });
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotificationToList(
        message.notification?.title ?? 'No Title',
        message.notification?.body ?? 'No Body',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.body ?? 'Notification received'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _addNotificationToList(String title, String body) {
    setState(() {
      final timestamp = DateTime.now().toString().split('.')[0];
      _receivedNotifications.insert(
        0,
        '[$timestamp] $title: $body',
      );
      // Keep only last 10 notifications
      if (_receivedNotifications.length > 10) {
        _receivedNotifications.removeLast();
      }
    });
  }

  Future<void> _toggleTopic(String topic) async {
    final isSubscribed = _subscribedTopics[topic] ?? false;

    if (isSubscribed) {
      await _notificationService.unsubscribeFromTopic(topic);
    } else {
      await _notificationService.subscribeToTopic(topic);
    }

    setState(() {
      _subscribedTopics[topic] = !isSubscribed;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSubscribed ? 'Unsubscribed from $topic' : 'Subscribed to $topic',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyCTokenToClipboard() {
    if (_fcmToken != null) {
      // Copy token to clipboard (you might use native support)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM token visible below - copy from the text'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearNotificationHistory() {
    setState(() {
      _receivedNotifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification history cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Demo'),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _notificationsEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: _notificationsEnabled
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notification Status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _notificationsEnabled ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  color: _notificationsEnabled
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // FCM Token Section
              const Text(
                'Device FCM Token',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_fcmToken != null)
                        Text(
                          _fcmToken!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Courier',
                            color: Colors.black87,
                          ),
                          maxLines: null,
                        )
                      else
                        const Text(
                          'Loading token...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _copyCTokenToClipboard,
                        icon: const Icon(Icons.content_copy, size: 16),
                        label: const Text('Copy Token'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Topic Subscriptions
              const Text(
                'Subscribe to Topics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._topics.map((topic) {
                return Card(
                  child: CheckboxListTile(
                    title: Text(topic),
                    subtitle: const Text('Receive notifications for this topic'),
                    value: _subscribedTopics[topic] ?? false,
                    onChanged: (value) {
                      _toggleTopic(topic);
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),

              // How to Test Section
              const Text(
                'How to Test Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '1. Firebase Console Method:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Go to Firebase Console > Messaging\n'
                        '• Create a new campaign\n'
                        '• Send to a specific device using the FCM token above\n'
                        '• Or send to a topic that you\'ve subscribed to',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '2. Cloud Functions Method:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Deploy a Cloud Function to send notifications\n'
                        '• Call the function with your user ID\n'
                        '• See NOTIFICATION_BACKEND_EXAMPLES.js for code',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '3. Using cURL:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        '''curl -X POST https://fcm.googleapis.com/fcm/send \\
  -H "Content-Type: application/json" \\
  -H "Authorization: key=YOUR_SERVER_KEY" \\
  -d '{"to":"${_fcmToken ?? "FCM_TOKEN"}","notification":{"title":"Test","body":"Hello!"}}' ''',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Courier',
                          backgroundColor: Color(0xFFFFECB3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Received Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Received Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearNotificationHistory,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_receivedNotifications.isEmpty)
                Card(
                  color: Colors.grey[100],
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No notifications received yet.\n'
                        'Send a test notification to see it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _receivedNotifications.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _receivedNotifications[index],
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),

              // Info Section
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '📌 Important Setup Notes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are configured\n'
                        '• Check Firebase Console has FCM enabled\n'
                        '• iOS requires APNs certificate configuration\n'
                        '• Allow notification permissions when prompted on first app launch\n'
                        '• See PUSH_NOTIFICATIONS_SETUP.md for detailed setup instructions',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
