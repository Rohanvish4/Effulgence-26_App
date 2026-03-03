import '../../domain/entities/referral_entity.dart';

class ReferralModel extends ReferralEntity {
  const ReferralModel({
    required super.id,
    required super.name,
    required super.email,
    super.registrationId,
    super.isInternalUser,
    super.collegeName,
    super.mobile,
    super.createdAt,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      registrationId: json['registrationId'],
      isInternalUser: json['isInternalUser'] ?? false,
      collegeName: json['collegeName'],
      mobile: json['mobile']?.toString(),
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
