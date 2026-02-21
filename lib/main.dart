import 'package:effulgence26_mobile_app/app.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:effulgence26_mobile_app/core/services/analytics_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background FCM: ${message.messageId}');
}

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Load Environment Variables ───────────────────────────────────────────
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment variables loaded successfully from .env');
  } catch (e) {
    debugPrint('Warning: Failed to load .env file: $e');
    debugPrint('Make sure .env file exists in the project root and is listed in pubspec.yaml');
  }

  // ─── Global Error Handling ────────────────────────────────────────────────

  if (!kDebugMode) {
    // Flutter framework errors (e.g. widget build errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); // still print to console
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // Also log to analytics for user-specific error tracking
      AnalyticsService.instance.logError(
        errorType: 'flutter_error',
        errorMessage: details.exception.toString(),
        additionalData: <String, Object>{
          'context': details.context.toString(),
        },
      );
    };

    //  Dart async / platform-channel errors not caught by Flutter framework
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // Also log to analytics
      AnalyticsService.instance.logError(
        errorType: 'platform_error',
        errorMessage: error.toString(),
      );
      return true; // "handled"
    };
  } else {
    //  (red screen errors, still forward to Crashlytics so we can see the error count.
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
  }

  // ─── Firebase Cloud Messaging ─────────────────────────────────────────────
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  runApp(const MyApp());
}