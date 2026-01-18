/// User entity for domain layer
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final String? profilePic;
  final int mobile;
  final String? phone;
  final int rollNo;
  final String role;
  final bool isEmailVerified;
  final bool isVerified;
  final bool isInternalUser;
  final String approvalStatus;
  final String? collegeName;
  final String? effulgenceId;
  final List<String> managedDomains;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.profilePic,
    required this.mobile,
    this.phone,
    required this.rollNo,
    this.role = 'USER',
    this.isEmailVerified = false,
    this.isVerified = false,
    this.isInternalUser = false,
    this.approvalStatus = 'PENDING',
    this.collegeName,
    this.effulgenceId,
    this.managedDomains = const [],
    this.createdAt,
    this.updatedAt,
  });

  // ─────────────────────────────
  // Computed Role & Status Flags
  // ─────────────────────────────
  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isApproved => approvalStatus == 'APPROVED';
  bool get isPending => approvalStatus == 'PENDING';
  bool get isRejected => approvalStatus == 'REJECTED';

  // ─────────────────────────────
  // CopyWith for Controlled Mutations
  // ─────────────────────────────
  UserEntity copyWith({
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
    return UserEntity(
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
