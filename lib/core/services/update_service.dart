import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(
            hours: 1,
          ), // Check every hour in prod
        ),
      );

      // Default values
      await _remoteConfig.setDefaults({
        'android_min_version': '1.0.0',
        'ios_min_version': '1.0.0',
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Allow app to continue if remote config fails (fail open)
      print('Remote Config init failed: $e');
    }
  }

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
      return _remoteConfig.getString('android_min_version');
    } else if (Platform.isIOS) {
      return _remoteConfig.getString('ios_min_version');
    }
    return '1.0.0';
  }

  bool _isCurrentVersionLower(String current, String min) {
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
    return false;
  }

  String getStoreUrl() {
    if (Platform.isAndroid) {
      // Replace with your actual package name or Play Store URL
      return 'https://play.google.com/store/apps/details?id=in.effulgence26.app';
    } else if (Platform.isIOS) {
      // Replace with your actual App Store URL
      //TODO: Add App Store URL
    }
    return '';
  }
}
