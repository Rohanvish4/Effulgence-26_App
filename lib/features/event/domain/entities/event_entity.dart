/// Event entity for domain layer
class EventEntity {
  final String id;
  final String title;
  final String? coverImage;
  final String? description;
  final String? rules;
  final String domain; // Changed from domainId to match API
  final int eventRound;
  final String eventType;
  final TeamConfig? teamConfig; // New field
  final String eventVenue; // Changed from venue
  final DateTime eventTime;
  final DateTime? endTime; // New field
  final DateTime registrationDeadline;
  final String status;
  final bool isDeleted; // New field
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    this.coverImage,
    this.description,
    this.rules,
    required this.domain,
    // this.domainName,
    this.eventRound = 1,
    required this.eventType,
    // this.minTeamSize = 1,
    // this.maxTeamSize = 10,
    required this.eventVenue,
    required this.eventTime,
    required this.registrationDeadline,
    required this.status,
    // this.registeredUsers = const [],
    this.createdAt,
    this.updatedAt,
    this.teamConfig,
    this.endTime,
    required this.isDeleted,
  });

  // Computed properties
  bool get isUpcoming => status == 'UPCOMING';
  bool get isLive => status == 'LIVE';
  bool get isCompleted => status == 'COMPLETED';
  bool get isIndividual => eventType == 'INDIVIDUAL';
  bool get isTeam => eventType == 'TEAM';
  bool get canRegister =>
      !isDeleted &&
      DateTime.now().isBefore(registrationDeadline) &&
      !isCompleted;

  int get minTeamSize => teamConfig?.minSize ?? 1;
  int get maxTeamSize => teamConfig?.maxSize ?? 10;

  // UI convenience getters
  String get domainName => domain;
  String get venue => eventVenue;
  int get registeredCount =>
      0; 
}

class TeamConfig {
  final int minSize;
  final int maxSize;

  const TeamConfig({required this.minSize, required this.maxSize});
}
