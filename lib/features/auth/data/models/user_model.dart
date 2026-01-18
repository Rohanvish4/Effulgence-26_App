import 'package:effulgence26_mobile_app/features/auth/domain/entity/user_entity.dart';

/// User model for data layer
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.imageUrl,
    super.profilePic,
    required super.mobile,
    super.phone,
    required super.rollNo,
    super.role,
    super.isEmailVerified,
    super.isVerified,
    super.isInternalUser,
    super.approvalStatus,
    super.collegeName,
    super.effulgenceId,
    super.managedDomains,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      profilePic: json['profilePic'] ?? json['imageUrl'],
      mobile: json['mobile'] is int
          ? json['mobile']
          : int.tryParse(json['mobile']?.toString() ?? '0') ?? 0,
      phone: json['phone']?.toString() ?? json['mobile']?.toString(),
      rollNo: json['rollNo'] is int
          ? json['rollNo']
          : int.tryParse(json['rollNo']?.toString() ?? '0') ?? 0,
      role: json['role'] ?? 'USER',
      isEmailVerified: json['isEmailVerified'] ?? false,
      isVerified: json['isVerified'] ?? json['isEmailVerified'] ?? false,
      isInternalUser: json['isInternalUser'] ?? false,
      approvalStatus: json['approvalStatus'] ?? 'PENDING',
      collegeName: json['collegeName'] ?? json['college'],
      effulgenceId: json['effulgenceId'],
      managedDomains: json['managedDomains'] != null
          ? (json['managedDomains'] is List
                ? List<String>.from(
                    json['managedDomains'].map((e) => e.toString()),
                  )
                : [])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'profilePic': profilePic,
      'mobile': mobile,
      'phone': phone,
      'rollNo': rollNo,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'isVerified': isVerified,
      'isInternalUser': isInternalUser,
      'approvalStatus': approvalStatus,
      'collegeName': collegeName,
      'effulgenceId': effulgenceId,
      'managedDomains': managedDomains,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      imageUrl: entity.imageUrl,
      profilePic: entity.profilePic,
      mobile: entity.mobile,
      phone: entity.phone,
      rollNo: entity.rollNo,
      role: entity.role,
      isEmailVerified: entity.isEmailVerified,
      isVerified: entity.isVerified,
      isInternalUser: entity.isInternalUser,
      approvalStatus: entity.approvalStatus,
      collegeName: entity.collegeName,
      effulgenceId: entity.effulgenceId,
      managedDomains: entity.managedDomains,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Copy with
  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? profilePic,
    int? mobile,
    String? phone,
    int? rollNo,
    String? role,
    bool? isEmailVerified,
    bool? isVerified,
    bool? isInternalUser,
    String? approvalStatus,
    String? collegeName,
    String? effulgenceId,
    List<String>? managedDomains,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      profilePic: profilePic ?? this.profilePic,
      mobile: mobile ?? this.mobile,
      phone: phone ?? this.phone,
      rollNo: rollNo ?? this.rollNo,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isVerified: isVerified ?? this.isVerified,
      isInternalUser: isInternalUser ?? this.isInternalUser,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      collegeName: collegeName ?? this.collegeName,
      effulgenceId: effulgenceId ?? this.effulgenceId,
      managedDomains: managedDomains ?? this.managedDomains,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
