import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:effulgence26_mobile_app/router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import '../constants/app_constants.dart';
import '../network/api_client.dart';
 
class NotificationService {
  final ApiClient apiClient;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<_PendingNavigation> _pendingNavigations = <_PendingNavigation>[];
  bool _flushScheduled = false;
  bool _tapHandlersConfigured = false;
  bool _localNotificationsInitialized = false;

  AuthCubit? _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  NotificationService({required this.apiClient});

  void bindAuthCubit(AuthCubit authCubit) {
    if (_authCubit == authCubit) return;
    _authCubit = authCubit;

    _authSubscription?.cancel();
    _authSubscription = authCubit.stream.listen((_) {
      _flushPendingNavigations();
    });

    // In case we already queued a navigation before auth/router were ready.
    _flushPendingNavigations();
  }

  Future<void> initialize() async {
    // Always set up tap handling early.
    // Permission gating should only affect token sync and foreground display.
    _configureFcmTapHandlers();
    await _initializeLocalNotifications();

    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      criticalAlert: false,
    );

    debugPrint('User notification permission status: ${settings.authorizationStatus}');

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
      debugPrint('User granted permission');

      // 3. Subscribe to Broadcast Topic
      await _firebaseMessaging.subscribeToTopic('all_users');

      // 4. Get Token and Send to Backend
      _firebaseMessaging.getToken().then((token) {
        if (token != null) {
          syncFcmToken(token);
        }
      });

      // 5. Listen for Token Refreshes
      _firebaseMessaging.onTokenRefresh.listen(syncFcmToken);

      // 6. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        debugPrint('Message notification: ${message.notification}');
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      });
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;
    _localNotificationsInitialized = true;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Local notification tapped: ${details.payload}');
        _handleNotificationTap(details.payload);
      },
    );

    // If the app was launched by tapping a local notification (terminated state)
    // the tap callback above may not fire; this covers that case.
    final NotificationAppLaunchDetails? launchDetails =
        await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final String? payload = launchDetails?.notificationResponse?.payload;
    if (payload != null && payload.isNotEmpty) {
      debugPrint('App launched via local notification. Payload: $payload');
      _handleNotificationTap(payload);
    }
  }

  void _configureFcmTapHandlers() {
    if (_tapHandlersConfigured) return;
    _tapHandlersConfigured = true;

    // When app is in background and user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // When app is terminated and launched by tapping the notification
    // This must be called AFTER Firebase.initializeApp(), which is done in main().
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message == null) return;
      debugPrint('App launched via FCM notification. Data: ${message.data}');
      _handleBackgroundMessageTap(message);
    }).catchError((e) {
      debugPrint('Error reading initial FCM message: $e');
    });
  }

  Future<void> syncFcmToken([String? token]) async {
    try {
      final String? fcmToken = token ?? await _firebaseMessaging.getToken();
      if (fcmToken == null) return;

      debugPrint("Syncing FCM Token: $fcmToken");
      
      final prefs = await SharedPreferences.getInstance();
      final String? cachedToken = prefs.getString(AppConstants.cachedFcmTokenKey);

      if (cachedToken != fcmToken) {
        // Token has changed or is new, send to backend
        debugPrint("FCM Token changed. Updating backend...");
        await apiClient.updateFcmToken(fcmToken);
        // Update cache only after successful backend update
        await prefs.setString(AppConstants.cachedFcmTokenKey, fcmToken);
        debugPrint("FCM Token synced and cached.");
      } else {
        debugPrint("FCM Token is unchanged. Skipping backend update.");
      }
    } catch (e) {
      debugPrint("Error syncing FCM token: $e");
    }
  }

  Future<void> clearFcmToken() async {
    try {
      debugPrint("Clearing FCM Token...");

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.cachedFcmTokenKey);
    
      debugPrint("FCM Token cache cleared.");
    } catch (e) {
      debugPrint("Error clearing FCM token: $e");
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final String type = data['type']?.toString().toUpperCase() ?? '';
      final String id = data['id']?.toString() ?? '';

      debugPrint('Handling notification tap: type=$type, id=$id');
      _requestNavigation(type: type, id: id);
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  void _handleBackgroundMessageTap(RemoteMessage message) {
    debugPrint('Handling background message tap: ${message.data}');
    
    final String type = message.data['type']?.toString().toUpperCase() ?? '';
    // Check both relatedId and id
    final String id = message.data['relatedId']?.toString() ?? message.data['id']?.toString() ?? '';

    _requestNavigation(type: type, id: id);
  }

  void _requestNavigation({required String type, required String id}) {
    if (type.isEmpty) {
      debugPrint('Notification type is empty; cannot navigate');
      return;
    }

    _pendingNavigations.add(_PendingNavigation(type: type, id: id));
    _flushPendingNavigations();
  }

  void _flushPendingNavigations() {
    final context = AppRouter.rootNavigatorKey.currentContext;

    // Router isn't mounted yet
    if (context == null) {
      _scheduleFlush();
      return;
    }

    if (!context.mounted) {
      _scheduleFlush();
      return;
    }

    if (_pendingNavigations.isEmpty) return;

    // If auth is still loading or user isn't authenticated yet, wait.
    // This avoids GoRouter redirect sending us to /splash or /login and
    // effectively dropping the notification deep link.
    final authState = _authCubit?.state;
    final isLoading = authState is AuthLoading || authState is AuthInitial;
    final isAuthenticated = authState is AuthAuthenticated;
    final isRegistrationSuccess = authState is AuthRegistrationSuccess;
    final canNavigateToProtectedRoutes =
      !isLoading && (isAuthenticated || isRegistrationSuccess);

    if (!canNavigateToProtectedRoutes) {
      _scheduleFlush();
      return;
    }

    final pending = List<_PendingNavigation>.from(_pendingNavigations);
    _pendingNavigations.clear();

    // Execute after the current frame to avoid navigating during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        _pendingNavigations.addAll(pending);
        _scheduleFlush();
        return;
      }

      final router = GoRouter.of(context);
      for (final nav in pending) {
        _navigate(router: router, type: nav.type, id: nav.id);
      }
    });
  }

  void _scheduleFlush() {
    if (_flushScheduled) return;
    _flushScheduled = true;

    // Retry for a short window until the router context becomes available.
    Future<void>(() async {
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          break;
        }
      }
    }).whenComplete(() {
      _flushScheduled = false;
      _flushPendingNavigations();
    });
  }

  void _navigate({required GoRouter router, required String type, required String id}) {
    switch (type) {
      case 'EVENT':
        if (id.isNotEmpty) {
          router.pushNamed('eventDetails', pathParameters: {'id': id});
        } else {
          debugPrint('EVENT notification missing id; cannot navigate');
        }
        break;
      case 'ADMIN':
        router.pushNamed('notifications');
        break;
      case 'TEAM_INVITE':
        router.pushNamed('myInvitations');
        break;
      case 'TEAM_REQUEST':
      case 'TEAM_UPDATE':
        if (id.isNotEmpty) {
          router.pushNamed('teamManagement', pathParameters: {'eventId': id});
        } else {
          debugPrint('$type notification missing eventId; cannot navigate');
        }
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Extract data for deeper UI customization
      final String type = message.data['type'] ?? 'SYSTEM';
      final Color themeColor = _getNotificationColor(type);
      final String title = message.notification?.title ?? 'Notification';
      final String body = message.notification?.body ?? '';

      debugPrint('Showing local notification: $title - $body (type: $type)');

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
            icon: '@drawable/ic_notification',
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
          'id': message.data['relatedId'] ?? message.data['id'] ?? '',
        }),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
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
      case 'TEAM_INVITE':
      case 'TEAM_REQUEST':
      case 'TEAM_UPDATE':
        return const Color(0xFFF39C12); // Amber/Orange for Team activity
      default:
        return const Color(0xFF2DD4BF); // Primary Teal
    }
  }

  /// Dispose resources to prevent memory leaks
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _authCubit = null;
    _pendingNavigations.clear();
  }
}

class _PendingNavigation {
  final String type;
  final String id;

  const _PendingNavigation({required this.type, required this.id});
}
