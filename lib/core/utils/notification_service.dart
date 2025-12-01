import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
  print('Message notification: ${message.notification?.body}');
}

class NotificationService {
  final _firebaseMesaging = FirebaseMessaging.instance;
  static final NotificationService _instance = NotificationService._internal();
  
  //singleton
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  initFCM() async {
    final settings = await _firebaseMesaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );
    print('Permission granted: ${settings.authorizationStatus}');

    String? token = await _firebaseMesaging.getToken();
    print('Registration Token=$token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received Foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
        'Message received Background and tapped: ${message.notification?.title}',
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
