class UserProfileEntity {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final int mobile;
  final int rollNo;
  final String role;
  final bool isEmailVerified;
  final String approvalStatus;

  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.mobile,
    required this.rollNo,
    this.role = 'USER',
    this.isEmailVerified = false,
    this.approvalStatus = 'PENDING',
  });

  // Computed Role & Status Flags

  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isApproved => approvalStatus == 'APPROVED';
  bool get isPending => approvalStatus == 'PENDING';
  bool get isRejected => approvalStatus == 'REJECTED';

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    int? mobile,
    int? rollNo,
    String? role,
    bool? isEmailVerified,
    String? approvalStatus,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      mobile: mobile ?? this.mobile,
      rollNo: rollNo ?? this.rollNo,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}
