import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';
import '../services/analytics_service.dart';

/// API Client wrapper for Dio
class ApiClient {
  late final Dio _dio;
  late final PersistCookieJar _cookieJar;

  ApiClient({required PersistCookieJar cookieJar}) : _cookieJar = cookieJar {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add cookie manager for session persistence with PersistCookieJar
    // IMPORTANT: Add CookieManager FIRST so cookies are loaded before other interceptors
    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Performance monitoring- measure every request duration and flag slow calls
    _dio.interceptors.add(_PerformanceInterceptor());

    // Add logging in debug mode only
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  /// Request interceptor - adds auth token
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // For cookie-based authentication, let CookieManager handle cookies
    // Don't manually add Authorization header as backend uses HTTP-only cookies
    handler.next(options);
  }

  /// Response interceptor
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Error interceptor
  void _onError(DioException error, ErrorInterceptorHandler handler) {
    handler.next(error);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update FCM Token
  Future<void> updateFcmToken(String token) async {
    await post(
      ApiConstants.updateFcmToken,
      data: {'fcmToken': token},
    );
  }

  /// Get Notifications
  Future<Response> getNotifications({int page = 1, int limit = 10}) async {
    return await get(
      ApiConstants.notifications,
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  /// Mark a single notification as read
  Future<void> markNotificationRead(String notificationId) async {
    await put('${ApiConstants.markNotificationRead}$notificationId/read');
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsRead() async {
    await put(ApiConstants.markAllNotificationsRead);
  }

  /// Send broadcast notification (Admin only)
  /// If targetUserId is provided, sends to that specific user only
  /// targetType can be 'ALL', 'INTERNAL', or 'EXTERNAL' to filter recipients
  Future<Response> sendBroadcast({
    required String title,
    required String message,
    String? targetUserId,
    String targetType = 'ALL',
    String type = 'ADMIN',
    String? relatedId,
  }) async {
    return await post(
      ApiConstants.broadcastNotification,
      data: {
        'title': title,
        'message': message,
        'targetType': targetType,
        'type': type,
        if (targetUserId != null) 'targetUserId': targetUserId,
        if (relatedId != null && relatedId.isNotEmpty) 'relatedId': relatedId,
      },
    );
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout. Please try again.',
        );

      case DioExceptionType.connectionError:
        return NetworkException();

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return ServerException(message: 'Request cancelled');

      default:
        return ServerException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  /// Stream controller for session expiration events
  final _sessionExpiredController = StreamController<void>.broadcast();

  /// Stream of session expiration events
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  void dispose() {
    _sessionExpiredController.close();
  }

  /// Handle response errors based on status code
  AppException _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'An error occurred';
    if (data is Map<String, dynamic>) {
      final dynamic rawMessage = data['error'] ?? data['message'];
      if (rawMessage is String && rawMessage.isNotEmpty) {
        message = rawMessage;
      } else if (rawMessage != null) {
        message = jsonEncode(rawMessage);
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message: message, statusCode: statusCode);
      case 401:
        // Trigger session expiration event, unless it's a login or logout request
        // Login: 401 means invalid credentials, handled by UI
        // Logout: 401 means already logged out or invalid token, avoid infinite loop
        final path = response?.requestOptions.path;
        final isLogin = path?.endsWith(ApiConstants.login) ?? false;
        final isLogout = path?.endsWith(ApiConstants.logout) ?? false;

        if (!isLogin && !isLogout) {
          _sessionExpiredController.add(null);
        }
        return UnauthorizedException(message: message);
      case 403:
        // Return ServerException for 403 so the message is propagated to UI
        return ServerException(message: message, statusCode: statusCode);
      case 404:
        return NotFoundException(message: message);
      case 409:
        return ServerException(message: message, statusCode: statusCode);
      case 500:
      case 502:
      case 503:
        return ServerException(
          message: 'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Monitoring Interceptor
// ─────────────────────────────────────────────────────────────────────────────

/// Tracks every API request's duration.
/// - Logs all timings in debug mode.
/// - Reports slow calls (>= [_slowThresholdMs]) to [AnalyticsService].
class _PerformanceInterceptor extends Interceptor {
  /// Requests slower than this (ms) are flagged as slow.
  static const int _slowThresholdMs = 3000;

  /// We use the extra map in RequestOptions to carry the start timestamp
  /// through to the response/error callback.
  static const String _startTimeKey = '_requestStartTime';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _record(
      options: response.requestOptions,
      statusCode: response.statusCode ?? 0,
      isError: false,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _record(
      options: err.requestOptions,
      statusCode: err.response?.statusCode ?? 0,
      isError: true,
    );
    handler.next(err);
  }

  void _record({
    required RequestOptions options,
    required int statusCode,
    required bool isError,
  }) {
    final startTime = options.extra[_startTimeKey] as int?;
    if (startTime == null) return;

    final durationMs = DateTime.now().millisecondsSinceEpoch - startTime;
    final path = '${options.method} ${options.path}';
    final isSlow = durationMs >= _slowThresholdMs;

    if (kDebugMode) {
      final label = isSlow ? '..... SLOW' : '.... fast';
      debugPrint('$label API $path → $statusCode in ${durationMs}ms');
    }

    // Fire-and-forget analytics report (non-blocking)
    AnalyticsService.instance.logEvent('api_response_time', params: {
      'path': options.path,
      'method': options.method,
      'status_code': statusCode,
      'duration_ms': durationMs,
      'is_slow': isSlow.toString(),
      'is_error': isError.toString(),
    });

    if (isSlow) {
      AnalyticsService.instance.logEvent('slow_api_detected', params: {
        'path': options.path,
        'method': options.method,
        'duration_ms': durationMs,
        'threshold_ms': _slowThresholdMs,
        'status_code': statusCode,
      });
    }
  }
}
