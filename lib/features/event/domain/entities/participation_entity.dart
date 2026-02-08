// New entities for team management and registrations

class ParticipationUser {
  final String id;
  final String name;
  final String email;

  const ParticipationUser({
    required this.id,
    required this.name,
    required this.email,
  });
}

class ParticipationEntity {
  final String id;
  final String eventId;
  final ParticipationUser?
  user; // Nullable to handle cases where it might be missing or just ID
  final List<ParticipationUser> teamMembers; // For team events
  final String? teamName;
  final String participationType; // 'INDIVIDUAL' or 'TEAM'
  final DateTime registeredAt;
  final bool isPresent;
  final DateTime? markedPresentAt;
  final int? rank;
  final int score;
  final bool isQualified;
  final String? remarks;

  const ParticipationEntity({
    required this.id,
    required this.eventId,
    this.user,
    required this.teamMembers,
    this.teamName,
    required this.participationType,
    required this.registeredAt,
    required this.isPresent,
    this.markedPresentAt,
    this.rank,
    required this.score,
    required this.isQualified,
    this.remarks,
  });

  // Computed properties
  bool get isIndividual => participationType == 'INDIVIDUAL';
  bool get isTeam => participationType == 'TEAM';
    String get userId => user?.id ?? (teamMembers.isNotEmpty ? teamMembers[0].id : '');
    String get userName =>
      user?.name ?? (teamMembers.isNotEmpty ? teamMembers[0].name : 'Unknown');
    String get userEmail =>
      user?.email ?? (teamMembers.isNotEmpty ? teamMembers[0].email : '');

  List<String> get teamMemberNames =>
      teamMembers.map((member) => member.name).toList();
  List<String> get teamMemberEmails =>
      teamMembers.map((member) => member.email).toList();
}

class TeamEntity {
  final String participationId;
  final String teamName;
  final String eventId;
  final List<String> memberIds;
  final String leaderId;
  final DateTime createdAt;

  const TeamEntity({
    required this.participationId,
    required this.teamName,
    required this.eventId,
    required this.memberIds,
    required this.leaderId,
    required this.createdAt,
  });

  
}