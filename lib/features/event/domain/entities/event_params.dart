import '../entities/event_entity.dart';

/// Parameters for creating an event
class CreateEventParams {
  final String title;
  final String? description;
  final String? rules;
  final String domain;
  final String eventType;
  final String eventVenue;
  final DateTime eventTime;
  final DateTime registrationDeadline;
  final TeamConfig? teamConfig;

  const CreateEventParams({
    required this.title,
    this.description,
    this.rules,
    required this.domain,
    required this.eventType,
    required this.eventVenue,
    required this.eventTime,
    required this.registrationDeadline,
    this.teamConfig,
  });
}

/// Parameters for updating an event
class UpdateEventParams {
  final String? title;
  final String? description;
  final String? rules;
  final String? domain;
  final String? eventType;
  final String? eventVenue;
  final DateTime? eventTime;
  final DateTime? registrationDeadline;
  final TeamConfig? teamConfig;

  const UpdateEventParams({
    this.title,
    this.description,
    this.rules,
    this.domain,
    this.eventType,
    this.eventVenue,
    this.eventTime,
    this.registrationDeadline,
    this.teamConfig,
  });
}

/// Parameters for creating a team
class CreateTeamParams {
  final String eventId;
  final String teamName;

  const CreateTeamParams({required this.eventId, required this.teamName});
}
