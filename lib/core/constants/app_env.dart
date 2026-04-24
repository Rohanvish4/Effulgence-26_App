import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';


class AppEnv {
  AppEnv._();

  // ---------------------------------------------------------------------------
  // Google OAuth
  // ---------------------------------------------------------------------------

  /// Server-side OAuth 2.0 Client ID for Google Sign-In.
  /// Loaded from .env file: GOOGLE_SERVER_CLIENT_ID
  static String get googleServerClientId {
    final value = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'GOOGLE_SERVER_CLIENT_ID not found in .env file. '
        'Google Sign-In will not work without this configuration.',
      );
      return '';
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // App Environment
  // ---------------------------------------------------------------------------

  /// Current environment: 'dev' | 'staging' | 'prod'
  /// Loaded from .env file: APP_ENV (defaults to 'prod')
  static String get environment => dotenv.env['APP_ENV'] ?? 'prod';

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProd => environment == 'prod';

  // ---------------------------------------------------------------------------
  // Demo Mode
  // ---------------------------------------------------------------------------

  /// When true, all API calls are replaced with static mock data so the app
  /// works without a running backend (e.g. post-event Play Store showcase).
  static bool get isDemoMode => dotenv.env['DEMO_MODE'] == 'true';

  // ---------------------------------------------------------------------------
  // API Configuration
  // ---------------------------------------------------------------------------

  /// Base URL for API calls.
  /// Loaded from .env file: API_BASE_URL
  /// Defaults to production URL if not found (for safety during development)
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'API_BASE_URL not found in .env file. '
        'Using default production URL: https://api.effulgence26.in/',
      );
      return 'https://api.effulgence26.in/';
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // App Information
  // ---------------------------------------------------------------------------

  /// App package name for store URLs.
  /// Loaded from .env file: APP_PACKAGE_NAME
  static String get appPackageName {
    final value = dotenv.env['APP_PACKAGE_NAME'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'APP_PACKAGE_NAME not found in .env file. '
        'Using default: in.effulgence26.app',
      );
      return 'in.effulgence26.app';
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // Website URLs
  // ---------------------------------------------------------------------------

  /// Base URL for the website.
  /// Loaded from .env file: WEBSITE_BASE_URL
  static String get websiteBaseUrl {
    final value = dotenv.env['WEBSITE_BASE_URL'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'WEBSITE_BASE_URL not found in .env file. '
        'Using default: https://www.effulgence26.in',
      );
      return 'https://www.effulgence26.in';
    }
    return value;
  }

  /// Forgot password URL.
  /// Loaded from .env file: FORGOT_PASSWORD_URL
  static String get forgotPasswordUrl {
    final value = dotenv.env['FORGOT_PASSWORD_URL'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'FORGOT_PASSWORD_URL not found in .env file. '
        'Using default: https://www.effulgence26.in/forgot-password',
      );
      return 'https://www.effulgence26.in/forgot-password';
    }
    return value;
  }

  // ---------------------------------------------------------------------------
  // Firebase Configuration
  // ---------------------------------------------------------------------------

  /// Firebase project ID (optional - for different environments).
  /// Loaded from .env file: FIREBASE_PROJECT_ID
  static String? get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'];

  // ---------------------------------------------------------------------------
  // Store URLs
  // ---------------------------------------------------------------------------

  /// Play Store URL for the app.
  /// Loaded from .env file: PLAY_STORE_URL
  static String get playStoreUrl {
    final value = dotenv.env['PLAY_STORE_URL'];
    if (value == null || value.isEmpty) {
      debugPrint(
        'PLAY_STORE_URL not found in .env file. '
        'Using default Play Store URL.',
      );
      return 'https://play.google.com/store/apps/details?id=in.effulgence26.app';
    }
    return value;
  }

  /// App Store URL for the app (optional - iOS only).
  /// Loaded from .env file: APP_STORE_URL
  static String? get appStoreUrl => dotenv.env['APP_STORE_URL'];
}
