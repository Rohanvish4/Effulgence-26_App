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
  final bool isInternalUser;
  final bool isBlocked;
  final String qrcode;
  final String? paymentReceiptUrl;
  final String? collegeName;
  final String? registrationId;

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
    this.isInternalUser = false,
    this.isBlocked = false,
    this.qrcode = '',
    this.paymentReceiptUrl,
    this.collegeName,
    this.registrationId,
  });

  // Computed Role & Status Flags

  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';
  bool get isApprover => role == 'APPROVER';

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
    bool? isInternalUser,
    bool? isBlocked,
    String? qrcode,
    String? paymentReceiptUrl,
    String? collegeName,
    String? registrationId,
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
      isInternalUser: isInternalUser ?? this.isInternalUser,
      isBlocked: isBlocked ?? this.isBlocked,
      qrcode: qrcode ?? this.qrcode,
      paymentReceiptUrl: paymentReceiptUrl ?? this.paymentReceiptUrl,
      collegeName: collegeName ?? this.collegeName,
      registrationId: registrationId ?? this.registrationId,
    );
  }
}
