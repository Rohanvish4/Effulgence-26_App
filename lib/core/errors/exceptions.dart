/// Base Exception class
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Server exception for API errors
class ServerException extends AppException {
  ServerException({required super.message, super.statusCode});
}

/// Cache exception for local storage errors
class CacheException extends AppException {
  CacheException({required super.message});
}

/// Network exception for connectivity issues
class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection'});
}

/// Authentication exception
class AuthException extends AppException {
  AuthException({required super.message, super.statusCode});
}

/// Unauthorized exception - token expired or invalid
class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Session expired. Please login again.',
    super.statusCode = 401,
  });
}

/// Forbidden exception - insufficient permissions
class ForbiddenException extends AppException {
  ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
    super.statusCode = 403,
  });
}

/// Not found exception
class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'Resource not found.',
    super.statusCode = 404,
  });
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException({
    required super.message,
    this.fieldErrors,
    super.statusCode = 400,
  });
}
