// New entities for team management and registrations

class ParticipationEntity {
  final String id;
  final String eventId;
  final String userId;
  final List<String> teamMembers; // For team events
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
    required this.userId,
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