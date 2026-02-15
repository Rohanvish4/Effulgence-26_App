import 'dart:convert';
import 'dart:io';

import 'package:effulgence26_mobile_app/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';

/// Top-level background message handler
Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Background message data: ${message.data}');
  // Initialize local notifications for showing notification in background
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  // Android setup if not already done
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'effulgence_alerts',
            'Effulgence System Alerts',
            description: 'Critical event and system updates',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            ledColor: Color(0xFF2DD4BF),
          ),
        );
  }

  // You can also show a local notification here if needed
  if (message.notification != null) {
    print('Background message has notification, showing local notification');
  }
}
 
class NotificationService {
  final ApiClient apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService({required this.apiClient});

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      criticalAlert: false,
    );

    print('User notification permission status: ${settings.authorizationStatus}');

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'effulgence_alerts', // id
              'Effulgence System Alerts', // name
              description: 'Critical event and system updates',
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              ledColor: Color(0xFF2DD4BF), // Your Primary Teal
            ),
          );
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // 2. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          print('Notification tapped: ${details.payload}');
          // Handle notification tap if needed
          _handleNotificationTap(details.payload);
        },
      );

      // 3. Subscribe to Broadcast Topic
      await _firebaseMessaging.subscribeToTopic('all_users');

      // 4. Get Token and Send to Backend
      _firebaseMessaging.getToken().then((token) {
        if (token != null) {
          _sendTokenToBackend(token);
        }
      });

      // 5. Listen for Token Refreshes
      _firebaseMessaging.onTokenRefresh.listen(_sendTokenToBackend);

      // 6. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification}');
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });

      // 7. Handle Background Message Taps (from terminated/background state)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message opened app: ${message.data}');
        _handleBackgroundMessageTap(message);
      });

      // 8. Handle Background Messages (app in background)
      // Note: This must be a top-level or static function for background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    print("New FCM Token: $token");
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedToken = prefs.getString(AppConstants.cachedFcmTokenKey);

      if (cachedToken != token) {
        // Token has changed or is new, send to backend
        print("FCM Token changed. Updating backend...");
        await apiClient.updateFcmToken(token);
        // Update cache only after successful backend update
        await prefs.setString(AppConstants.cachedFcmTokenKey, token);
        print("FCM Token synced and cached.");
      } else {
        print("FCM Token is unchanged. Skipping backend update.");
      }
    } catch (e) {
      print("Error updating FCM token: $e");
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String type = data['type']?.toString().toUpperCase() ?? '';
      final String id = data['id']?.toString() ?? '';

      print('Handling notification tap: type=$type, id=$id');

      if (type == 'EVENT' && id.isNotEmpty) {
        // Use the global navigator key to push the event details page
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null) {
          // We can use GoRouter/Navigator directly since we are inside the app context
           // Using a slight delay to ensure the app is ready if launched from terminated state
           Future.delayed(const Duration(milliseconds: 200), () {
             if (context.mounted) { // Check mounted for safety though root context usually is
                GoRouter.of(context).pushNamed('eventDetails', pathParameters: {'id': id});
             }
           });
        } else {
             print('Navigator context is null, cannot navigate');
        }
      }

      if(type == 'ADMIN'){
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null) {
          // We can use GoRouter/Navigator directly since we are inside the app context
           // Using a slight delay to ensure the app is ready if launched from terminated state
           Future.delayed(const Duration(milliseconds: 200), () {
             if (context.mounted) { // Check mounted for safety though root context usually is
                GoRouter.of(context).pushNamed('notifications');
             }
           });
        } else {
             print('Navigator context is null, cannot navigate');
        }
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
      // Fallback
    }
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    // Handle background/terminated state message tap
    print('Handling background message tap: ${message.data}');
  }

  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'high_importance_channel', // id
  //     'High Importance Notifications', // title
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);

  //   await _flutterLocalNotificationsPlugin.show(
  //     message.hashCode,
  //     message.notification?.title,
  //     message.notification?.body,
  //     platformChannelSpecifics,
  //   );
  // }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Extract data for deeper UI customization
      final String type = message.data['type'] ?? 'SYSTEM';
      final Color themeColor = _getNotificationColor(type);
      final String title = message.notification?.title ?? 'Notification';
      final String body = message.notification?.body ?? '';

      print('Showing local notification: $title - $body (type: $type)');

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'effulgence_alerts',
            'Effulgence System Alerts',
            channelDescription: 'Critical event and system updates',
            importance: Importance.max,
            // sound: const RawResourceAndroidNotificationSound('notification'),
            priority: Priority.high,
            color: themeColor,
            colorized: true,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: '<b>$title</b>',
              summaryText: '$type',
              htmlFormatContentTitle: true,
              htmlFormatSummaryText: true,
            ),
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            enableVibration: true,
            playSound: true,
          );

      final DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: type,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode({
          'type': type,
          'id': message.data['relatedId'] ?? '',
        }),
      );
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toUpperCase()) {
      case 'EVENT':
        return const Color(0xFF6C63FF); // Purple
      case 'ADMIN':
        return const Color(0xFF00B894); // Green
      case 'REMINDER':
        return const Color(0xFFFFB74D); // Orange
      case 'SYSTEM':
        return const Color(0xFF2DD4BF); // Teal
      default:
        return const Color(0xFF2DD4BF); // Primary Teal
    }
  }
}
