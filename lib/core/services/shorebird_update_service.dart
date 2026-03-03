import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Service for Shorebird OTA (Over-The-Air) patch updates.
///
/// Shorebird patches are lightweight code-only updates (no asset changes) that
/// are applied on the next app restart. This complements the existing
/// [RemoteConfigService] forced-update mechanism:
///
/// - [RemoteConfigService] → enforces minimum app version (major/breaking
///   releases distributed via Play Store / App Store).
/// - [ShorebirdUpdateService] → silently downloads bugfix/hotfix patches and
///   applies them on the next cold start without app store review.
///
/// Usage:
///   final result = await ShorebirdUpdateService.instance.checkAndDownloadPatch();
///   if (result == ShorebirdPatchResult.downloaded) {
///     // Show "Restart to apply update" snackbar
///   }
///
class ShorebirdUpdateService {
  ShorebirdUpdateService._();

  static final ShorebirdUpdateService instance = ShorebirdUpdateService._();

  final ShorebirdCodePush _codePush = ShorebirdCodePush();

  /// Returns `true` if the app was compiled with Shorebird (i.e. released via
  /// `shorebird release`). Always `false` in debug / profile builds.
  bool get isShorebirdAvailable => _codePush.isShorebirdAvailable();

  /// Silently checks for an available OTA patch and downloads it if found.
  ///
  /// Returns:
  /// - [ShorebirdPatchResult.downloaded] – patch downloaded, restart required.
  /// - [ShorebirdPatchResult.upToDate]   – app is already on the latest patch.
  /// - [ShorebirdPatchResult.unavailable] – Shorebird not available in this build.
  /// - [ShorebirdPatchResult.error]       – check/download failed (non-fatal).
  Future<ShorebirdPatchResult> checkAndDownloadPatch() async {
    if (!isShorebirdAvailable) {
      debugPrint('[Shorebird] Not available in this build (debug/profile or '
          'not a shorebird release). Skipping OTA check.');
      return ShorebirdPatchResult.unavailable;
    }

    try {
      final isAvailable = await _codePush.isNewPatchAvailableForDownload();

      if (!isAvailable) {
        debugPrint('[Shorebird] App is up to date. No patch needed.');
        return ShorebirdPatchResult.upToDate;
      }

      // Patch available — download it silently.
      debugPrint('[Shorebird] Patch available. Downloading…');
      await _codePush.downloadUpdateIfAvailable();
      debugPrint('[Shorebird] Patch downloaded. Will apply on next restart.');
      return ShorebirdPatchResult.downloaded;
    } catch (e, stack) {
      debugPrint('[Shorebird] OTA check/download failed: $e\n$stack');
      return ShorebirdPatchResult.error;
    }
  }

  /// Returns the current patch number installed on this device, or `null` if
  /// running on the base release (patch 0) or Shorebird is unavailable.
  Future<int?> currentPatchNumber() async {
    if (!isShorebirdAvailable) return null;
    try {
      return await _codePush.currentPatchNumber();
    } catch (_) {
      return null;
    }
  }

  /// Returns the next patch number that will be applied on the next restart,
  /// or `null` if no patch is pending or Shorebird is unavailable.
  Future<int?> nextPatchNumber() async {
    if (!isShorebirdAvailable) return null;
    try {
      return await _codePush.nextPatchNumber();
    } catch (_) {
      return null;
    }
  }
}

/// Result of a Shorebird OTA patch check.
enum ShorebirdPatchResult {
  /// A patch was successfully downloaded and will be applied on next restart.
  downloaded,

  /// The app is already running the latest available patch.
  upToDate,

  /// Shorebird is not available in this build (debug / non-shorebird release).
  unavailable,

  /// An error occurred during the check or download (non-fatal).
  error,
}
