import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralised analytics service wrapping Firebase Analytics.
///
/// Usage:
///   final analytics = AnalyticsService.instance;
///   analytics.logScreenView(screenName: 'EventDetails');
///   analytics.logEvent('event_register', params: {'event_id': id});
///
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _fa = FirebaseAnalytics.instance;

  // ---------------------------------------------------------------------------
  // Screen Tracking
  // ---------------------------------------------------------------------------

  /// Call this from every page's initState or RouteAware to track screen views.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) return;
    await _fa.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ---------------------------------------------------------------------------
  // Generic Event
  // ---------------------------------------------------------------------------

  Future<void> logEvent(
    String name, {
    Map<String, Object>? params,
  }) async {
    if (kDebugMode) return;
    await _fa.logEvent(name: name, parameters: params);
  }

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  Future<void> logLogin({required String method}) async {
    if (kDebugMode) return;
    await _fa.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) async {
    if (kDebugMode) return;
    await _fa.logSignUp(signUpMethod: method);
  }

  Future<void> setUserId(String? userId) async {
    if (kDebugMode) return;
    await _fa.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (kDebugMode) return;
    await _fa.setUserProperty(name: name, value: value);
  }

  // ---------------------------------------------------------------------------
  // Events Feature
  // ---------------------------------------------------------------------------

  Future<void> logEventViewed(String eventId, String eventName) async {
    await logEvent('event_viewed', params: {
      'event_id': eventId,
      'event_name': eventName,
    });
  }

  Future<void> logEventRegistered(String eventId, String eventName) async {
    await logEvent('event_registered', params: {
      'event_id': eventId,
      'event_name': eventName,
    });
  }

  Future<void> logTeamCreated(String eventId) async {
    await logEvent('team_created', params: {'event_id': eventId});
  }

  Future<void> logTeamJoined(String eventId, String teamId) async {
    await logEvent('team_joined', params: {
      'event_id': eventId,
      'team_id': teamId,
    });
  }

  // ---------------------------------------------------------------------------
  // QR Code
  // ---------------------------------------------------------------------------

  Future<void> logQrScanned({required bool success}) async {
    await logEvent('qr_scanned', params: {'success': success.toString()});
  }

  // ---------------------------------------------------------------------------
  // Slow Screen Tracking
  // ---------------------------------------------------------------------------

  /// Use this to measure how long a screen takes to load.
  ///
  /// Example:
  ///   final stopwatch = analytics.startScreenTimer('EventDetails');
  ///   await loadData();
  ///   analytics.stopScreenTimer(stopwatch, 'EventDetails');
  Stopwatch startScreenTimer() => Stopwatch()..start();

  /// Log a slow screen load if it exceeds [thresholdMs] milliseconds (default 3 s).
  Future<void> stopScreenTimer(
    Stopwatch stopwatch,
    String screenName, {
    int thresholdMs = 3000,
  }) async {
    stopwatch.stop();
    final elapsedMs = stopwatch.elapsedMilliseconds;

    if (kDebugMode) {
      debugPrint('Screen "$screenName" loaded in ${elapsedMs}ms');
    }

    // Always log timing so we can analyse performance in Firebase
    await logEvent('screen_load_time', params: {
      'screen_name': screenName,
      'duration_ms': elapsedMs,
      'is_slow': (elapsedMs > thresholdMs).toString(),
    });

    if (elapsedMs > thresholdMs) {
      await logEvent('slow_screen_detected', params: {
        'screen_name': screenName,
        'duration_ms': elapsedMs,
        'threshold_ms': thresholdMs,
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Error & Problem Tracking
  // ---------------------------------------------------------------------------

  /// Log errors with full context for debugging user issues.
  /// This helps identify which users face which errors.
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
    Map<String, Object>? additionalData,
  }) async {
    debugPrint(
      'Error logged - Type: $errorType, Screen: $screenName, Message: $errorMessage',
    );

    final params = {
      'error_type': errorType,
      'error_message': errorMessage,
      if (screenName != null) 'screen_name': screenName,
      if (additionalData != null) ...additionalData,
    };

    await logEvent('app_error', params: params);
  }

  /// Log API errors specifically
  Future<void> logApiError({
    required String endpoint,
    required int statusCode,
    required String errorMessage,
    Map<String, Object>? additionalData,
  }) async {
    debugPrint(
      'API Error - Endpoint: $endpoint, Status: $statusCode, Message: $errorMessage',
    );

    final params = {
      'api_endpoint': endpoint,
      'status_code': statusCode.toString(),
      'error_message': errorMessage,
      if (additionalData != null) ...additionalData,
    };

    await logEvent('api_error', params: params);
  }

  /// Log validation errors
  Future<void> logValidationError({
    required String fieldName,
    required String validationMessage,
    String? screenName,
  }) async {
    await logEvent('validation_error', params: {
      'field_name': fieldName,
      'validation_message': validationMessage,
      if (screenName != null) 'screen_name': screenName,
    });
  }

  /// Log authentication errors
  Future<void> logAuthError({
    required String errorType,
    required String message,
  }) async {
    debugPrint('Auth Error - Type: $errorType, Message: $message');
    await logEvent('auth_error', params: {
      'error_type': errorType,
      'message': message,
    });
  }

  /// Log action completion for funnel analysis
  Future<void> logActionCompleted({
    required String actionName,
    required bool success,
    String? reason,
    Map<String, Object>? additionalData,
  }) async {
    final params = {
      'action': actionName,
      'success': success.toString(),
      if (reason != null) 'reason': reason,
      if (additionalData != null) ...additionalData,
    };

    await logEvent('action_completed', params: params);
  }
}
