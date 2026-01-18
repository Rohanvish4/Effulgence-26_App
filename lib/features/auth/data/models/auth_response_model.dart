import 'package:effulgence26_mobile_app/features/auth/domain/entity/auth_response_entity.dart';

import 'user_model.dart';

/// Auth response model for data layer
class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    super.token,
    required super.user,
    required super.message,
  });

  /// Create from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      'user': user != null ? (user as UserModel).toJson() : null,
      'message': message,
    };
  }
}
