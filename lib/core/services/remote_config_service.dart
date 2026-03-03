import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
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

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(minutes: 1), // Low interval for testing
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
      });

      await _remoteConfig.fetchAndActivate();
      print('Remote Config fetched and activated');
      print('Banner Visible: ${_remoteConfig.getBool(_keyHomeBannerVisible)}');
      print('Banner Text: ${_remoteConfig.getString(_keyHomeBannerText)}');
    } catch (e) {
      // Allow app to continue if remote config fails (fail open)
      print('Remote Config init failed: $e');
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
      print('Error parsing version: $e');
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
