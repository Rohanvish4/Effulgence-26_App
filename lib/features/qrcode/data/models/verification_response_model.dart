import '../../domain/entities/verification_response_entity.dart';

class VerificationResponseModel extends VerificationResponseEntity {
  const VerificationResponseModel({required super.valid, super.user});

  factory VerificationResponseModel.fromJson(Map<String, dynamic> json) {
    return VerificationResponseModel(
      valid: json['valid'] ?? false,
      user: json['user'] != null
          ? UserVerificationDetailsModel.fromJson(json['user'])
          : null,
    );
  }
}

class UserVerificationDetailsModel extends UserVerificationDetails {
  const UserVerificationDetailsModel({
    required super.name,
    required super.email,
    required super.registrationId,
    super.imageUrl,
    required super.collegeName,
    required super.isInternalUser,
  });

  factory UserVerificationDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserVerificationDetailsModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      registrationId: json['registrationId'] ?? '',
      imageUrl: json['imageUrl'],
      collegeName: json['collegeName'] ?? '',
      isInternalUser: json['isInternalUser'] ?? false,
    );
  }
}
