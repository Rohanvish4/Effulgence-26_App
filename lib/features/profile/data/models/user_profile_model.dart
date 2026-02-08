import 'package:effulgence26_mobile_app/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.imageUrl,
    required super.mobile,
    required super.rollNo,
    super.role,
    super.isEmailVerified,
    super.approvalStatus,
    super.isInternalUser,
    super.isBlocked,
    super.qrcode,
    super.paymentReceiptUrl,
    super.collegeName,
    super.registrationId,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      mobile: json['mobile'] is int
          ? json['mobile']
          : int.tryParse(json['mobile']?.toString() ?? '0') ?? 0,
      rollNo: json['rollNo'] is int
          ? json['rollNo']
          : int.tryParse(json['rollNo']?.toString() ?? '0') ?? 0,
      role: json['role'] ?? 'USER',
      isEmailVerified: json['isEmailVerified'] ?? false,
      approvalStatus: json['approvalStatus'] ?? 'PENDING',
      isInternalUser: json['isInternalUser'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      qrcode: json['qrcode'] ?? '',
      paymentReceiptUrl: json['paymentReceiptUrl'],
      collegeName: json['collegeName'] ?? json['college'],
      registrationId: json['registrationId'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'mobile': mobile,
      'rollNo': rollNo,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'approvalStatus': approvalStatus,
      'isInternalUser': isInternalUser,
      'isBlocked': isBlocked,
      'qrcode': qrcode,
      'paymentReceiptUrl': paymentReceiptUrl,
      'collegeName': collegeName,
      'registrationId': registrationId, 
    };

  }

  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      imageUrl: entity.imageUrl,
      mobile: entity.mobile,
      rollNo: entity.rollNo,
      role: entity.role,
      isEmailVerified: entity.isEmailVerified,
      approvalStatus: entity.approvalStatus,
      isInternalUser: entity.isInternalUser,
      isBlocked: entity.isBlocked,
      qrcode: entity.qrcode,
      paymentReceiptUrl: entity.paymentReceiptUrl,
      collegeName: entity.collegeName,  
      registrationId: entity.registrationId,
    );
  }
}
