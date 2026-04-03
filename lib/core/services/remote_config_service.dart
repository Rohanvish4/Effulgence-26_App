import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_env.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Keys
  static const String _keyAndroidMinVersion = 'android_min_version';
  static const String _keyIosMinVersion = 'ios_min_version';
  static const String _keyMaintenanceMode = 'maintenance_mode';
  static const String _keyHomeBannerText = 'home_banner_text';
  static const String _keyHomeBannerVisible = 'home_banner_visible';
  static const String _keyEnableSponsors = 'enable_sponsors';
  static const String _keyEnableRegistrations = 'enable_registrations';
  static const String _keyNotificationExpiryTime = 'notification_expiry_time';
  static const String _keyTechfestDay = 'techfest_day';
  static const String _keyShowEventSchedule = 'show_event_schedule';
    static const String _keyAccommodationReminderVisible =
      'accommodation_reminder_visible';
    static const String _keyAccommodationPaymentDeadline =
      'accommodation_payment_deadline';

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration(minutes: kDebugMode ? 1 : 720), // 1 min for debug, 12 hours for production
        ),
      );

      // Default values
      await _remoteConfig.setDefaults({
        _keyAndroidMinVersion: '1.0.0',
        _keyIosMinVersion: '1.0.0',
        _keyMaintenanceMode: false,
        _keyHomeBannerText: 'Welcome to Effulgence 26!',
        _keyHomeBannerVisible: false,
        _keyEnableSponsors: true,
        _keyEnableRegistrations: true,
        _keyNotificationExpiryTime: 24,
        _keyTechfestDay: 1,
        _keyShowEventSchedule: true,
        _keyAccommodationReminderVisible: true,
        _keyAccommodationPaymentDeadline: '2026-04-06',
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config fetched and activated');
      debugPrint('Banner Visible: ${_remoteConfig.getBool(_keyHomeBannerVisible)}');
      debugPrint('Banner Text: ${_remoteConfig.getString(_keyHomeBannerText)}');
    } catch (e) {
      // Allow app to continue if remote config fails (fail open)
      debugPrint('Remote Config init failed: $e');
    }
  }

  // --- Feature Flags & Dynamic Content ---

  bool get isMaintenanceMode => _remoteConfig.getBool(_keyMaintenanceMode);

  String get homeBannerText => _remoteConfig.getString(_keyHomeBannerText);

  bool get isHomeBannerVisible => _remoteConfig.getBool(_keyHomeBannerVisible);

  bool get areSponsorsEnabled => _remoteConfig.getBool(_keyEnableSponsors);

  bool get areRegistrationsEnabled => _remoteConfig.getBool(_keyEnableRegistrations);

  int get notificationExpiryTime => _remoteConfig.getInt(_keyNotificationExpiryTime); // in hours 

  int get techfestDay => _remoteConfig.getInt(_keyTechfestDay);

    bool get isEventScheduleVisible =>
      _remoteConfig.getBool(_keyShowEventSchedule);

  bool get isAccommodationReminderVisible =>
      _remoteConfig.getBool(_keyAccommodationReminderVisible);

  DateTime get accommodationPaymentDeadline {
    final raw = _remoteConfig.getString(_keyAccommodationPaymentDeadline).trim();
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return DateTime(2026, 4, 6);
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  // --- Update Logic ---

  Future<bool> isUpdateRequired() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      String minVersion = _getMinVersion();

      return _isCurrentVersionLower(currentVersion, minVersion);
    } catch (e) {
      return false;
    }
  }

  String _getMinVersion() {
    if (Platform.isAndroid) {
      return _remoteConfig.getString(_keyAndroidMinVersion);
    } else if (Platform.isIOS) {
      return _remoteConfig.getString(_keyIosMinVersion);
    }
    return '1.0.0';
  }

  bool _isCurrentVersionLower(String current, String min) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> minParts = min.split('.').map(int.parse).toList();

      for (int i = 0; i < minParts.length; i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        int minPart = minParts[i];

        if (currentPart < minPart) {
          return true;
        } else if (currentPart > minPart) {
          return false;
        }
      }
    } catch (e) {
      debugPrint('Error parsing version: $e');
    }
    return false;
  }

  String getStoreUrl() {
    if (Platform.isAndroid) {
      return AppEnv.playStoreUrl;
    } else if (Platform.isIOS) {
      return AppEnv.appStoreUrl ?? '';
    }
    return '';
  }
}
