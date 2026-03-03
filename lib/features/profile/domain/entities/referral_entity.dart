class ReferralEntity {
  final String id;
  final String name;
  final String email;
  final String? registrationId;
  final bool isInternalUser;
  final String? collegeName;
  final String? mobile;
  final DateTime? createdAt;

  const ReferralEntity({
    required this.id,
    required this.name,
    required this.email,
    this.registrationId,
    this.isInternalUser = false,
    this.collegeName,
    this.mobile,
    this.createdAt,
  });
}
