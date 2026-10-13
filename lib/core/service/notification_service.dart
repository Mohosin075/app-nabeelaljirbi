import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:nabeelaljirbi_app/core/const/app_colors.dart';
import 'package:nabeelaljirbi_app/core/const/shared_pref_helper.dart';
import 'package:nabeelaljirbi_app/core/route/routes.dart';
import 'package:nabeelaljirbi_app/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("🌙 [FCM Background Handler] Received message: ${message.messageId}");
  debugPrint("🌙 Data: ${message.data}");
}

class FCMNotificationService {
  static final FCMNotificationService _instance = FCMNotificationService._internal();
  factory FCMNotificationService() => _instance;
  FCMNotificationService._internal();

  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'default_channel',
    'Salama Notifications',
    description: 'Appointment reminders, confirmations, and alerts',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize all Notification handlers across Open, Background, Terminated states
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // 1. Request user notification permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('🔔 [FCM Permission Status]: ${settings.authorizationStatus}');

    // 2. iOS foreground presentation settings
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Android notification channel creation
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 4. Initialize Local Notifications Plugin
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 [Local Notification Tapped]: ${response.payload}');
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            handleNotificationRouting(data);
          } catch (e) {
            debugPrint('Error parsing notification payload: $e');
          }
        }
      },
    );

    // 5. Open / Foreground state handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('☀️ [FCM Foreground Message]: ${message.messageId}');
      debugPrint('☀️ Title: ${message.notification?.title}, Body: ${message.notification?.body}');
      debugPrint('☀️ Data: ${message.data}');

      _showForegroundNotification(message);
    });

    // 6. Background state handler (app in background, user taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📱 [FCM Background Notification Tapped]: ${message.messageId}');
      debugPrint('📱 Data: ${message.data}');
      handleNotificationRouting(message.data);
    });

    // 7. Terminated state handler (app closed/killed, opened via notification tap)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('⚡ [FCM Terminated Cold-Start]: ${message.messageId}');
        debugPrint('⚡ Data: ${message.data}');
        // Allow app initialization to complete before navigating
        Future.delayed(const Duration(milliseconds: 1500), () {
          handleNotificationRouting(message.data);
        });
      }
    });

    // 8. Token Refresh Listener
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔑 [FCM Token Refreshed]: $newToken');
      SharedPrefHelper.saveFcmToken(newToken);
    });
  }

  /// Display heads-up banner and local notification when app is open (Foreground)
  static void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Salama';
    final body = notification?.body ?? message.data['body'] ?? '';

    // Show Android / iOS heads-up notification
    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );

    // In-app interactive snackbar banner
    if (Get.context != null) {
      Get.rawSnackbar(
        titleText: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
        ),
        messageText: Text(
          body,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        backgroundColor: AppColors.primaryColor.withValues(alpha: 0.95),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        mainButton: TextButton(
          onPressed: () {
            if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
            handleNotificationRouting(message.data);
          },
          child: const Text(
            'عرض',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  /// Route user based on notification event type and appointment ID
  static void handleNotificationRouting(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final appointmentId = data['appointmentId'];
    final notificationType = data['notificationType'];
    final role = SharedPrefHelper.getUserRole()?.toLowerCase();

    debugPrint(
      '🚀 Routing for notificationType: $notificationType, appointmentId: $appointmentId, role: $role',
    );

    if (role == 'doctor') {
      if (Get.currentRoute != AppRoutes.doctorNotification) {
        Get.toNamed(
          AppRoutes.doctorNotification,
          arguments: {'appointmentId': appointmentId},
        );
      }
    } else {
      // Default to patient notification screen
      if (Get.currentRoute != AppRoutes.patientNotification) {
        Get.toNamed(
          AppRoutes.patientNotification,
          arguments: {'appointmentId': appointmentId},
        );
      }
    }
  }

  /// Retrieve current FCM token
  static Future<String?> getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        SharedPrefHelper.saveFcmToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }
}
