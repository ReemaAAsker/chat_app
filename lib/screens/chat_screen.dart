import 'package:chat_app/widgets/message_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _cloudfirebaseStore = FirebaseFirestore.instance;
const String collectionName = 'messages';
late User signedUser;

class ChatScreen extends StatefulWidget {
  static const String id = '/chat_screen';
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  TextEditingController usermsgController = TextEditingController();
  List<RemoteMessage> notifications = [];
  @override
  void initState() {
    super.initState();
    getCred();
    initLocalNotifications();
    setupPushNotifications();
  }

  /// 🔹 Get logged-in user
  void getCred() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signedUser = user;
        print('✅ Signed in as: ${signedUser.email}');
      }
    } catch (e) {
      print('❌ Error getting user: $e');
    }
  }

  /// 🔹 Initialize local notification plugin
  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📲 Notification tapped! Payload: ${response.payload}');
      },
    );

    print('✅ Local Notifications Initialized');
  }

  /// 🔹 Show a local notification
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'chat_channel', // Channel ID
          'Chat Notifications', // Channel name
          channelDescription: 'Notifications for new chat messages',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      0, // ID
      title,
      body,
      notificationDetails,
      payload: 'chat_message',
    );
  }

  /// 🔹 Setup Firebase Cloud Messaging
  void setupPushNotifications() async {
    // Request permission for iOS
    await _messaging.requestPermission();

    // Get FCM token
    final fcmToken = await _messaging.getToken();
    print('📱 FCM Token: $fcmToken');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '💌 Message received in foreground: ${message.notification?.title}',
      );
      setState(() {
        notifications.add(message);
      });
      _showLocalNotification(
        message.notification?.title ?? 'New Message',
        message.notification?.body ?? 'You received a new message!',
      );
    });

    // When user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Opened from notification!');
    });
  }

  /// 🔹 Send a chat message
  Future<void> sendMessage() async {
    final text = usermsgController.text.trim();
    if (text.isEmpty) return;

    await _cloudfirebaseStore.collection(collectionName).add({
      'text': text,
      'sender': signedUser.email,
      'time': FieldValue.serverTimestamp(),
    });

    // Optionally show a local notification when sending
    await _showLocalNotification('Message Sent', 'Your message was sent.');

    usermsgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[800],
        title: Row(
          children: [
            SizedBox(
              height: 50,
              width: 50,
              child: Image.asset('images/logo.jpg'),
            ),
            const SizedBox(width: 10),
            const Text("Let's Chat"),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              notifications.isNotEmpty
                  ? Positioned(
                      right: 11,
                      top: 11,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: Text(
                          notifications.length.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(firebaseFire: _cloudfirebaseStore),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.orange, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: usermsgController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue[800]),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
