/// App Constants for Effulgence'26 App
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = "Effulgence'26";
  static const String appTagline = 'INNOVATION AND BEYOND';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_complete';
  static const String cachedFcmTokenKey = 'cached_fcm_token';

  // Validation
  static const int minPasswordLength = 8;
  static const int minNameLength = 3;
  static const int phoneLength = 10;

  // Pagination
  static const int defaultPageSize = 10;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';
}
