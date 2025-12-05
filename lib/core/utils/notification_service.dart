import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:watering_app/core/utils/debug_print.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  printDebug("Handling a background message: ${message.messageId}");
  printDebug('Message data: ${message.data}');
  printDebug('Message notification: ${message.notification?.title}');
  printDebug('Message notification: ${message.notification?.body}');
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
    printDebug('Permission granted: ${settings.authorizationStatus}');

    String? token = await _firebaseMesaging.getToken();
    printDebug('Registration Token=$token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      printDebug('Message received Foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printDebug(
        'Message received Background and tapped: ${message.notification?.title}',
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
