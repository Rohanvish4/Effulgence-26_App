import 'package:dartz/dartz.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/participation_entity.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/public_team_entity.dart';
import '../../../../core/errors/failures.dart';
import '../entities/event_entity.dart';
import '../entities/event_params.dart';

/// Events repository interface
abstract class EventsRepository {
  /// Get all events (backend returns all events)
  Future<Either<Failure, List<EventEntity>>> getEvents();

  /// Get event by ID
  Future<Either<Failure, EventEntity>> getEventById(String id);

  /// Register for event
  Future<Either<Failure, void>> registerForEvent(String eventId);

  /// Unregister from event
  Future<Either<Failure, void>> unregisterFromEvent(String eventId);

  /// Get events registered by user
  Future<Either<Failure, List<EventEntity>>> getMyEvents();

  /// Search events
  Future<Either<Failure, List<EventEntity>>> searchEvents(String query);

  // New methods for different roles

  // USER operations
  Future<Either<Failure, void>> createTeam(CreateTeamParams params);
  Future<Either<Failure, List<ParticipationEntity>>> getMyParticipations();

  /// Get public teams for a team event
  Future<Either<Failure, List<PublicTeamEntity>>> getPublicTeams(
    String eventId,
  );

  /// Join an existing team
  Future<Either<Failure, void>> joinTeam(String eventId, String teamId);

  /// Leave a team
  Future<Either<Failure, void>> leaveTeam(String eventId, String teamId);

  // ADMIN/SUPER_ADMIN operations
  Future<Either<Failure, EventEntity>> createEvent(CreateEventParams params);
  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    UpdateEventParams params,
  );
  Future<Either<Failure, void>> deleteEvent(String eventId);
  Future<Either<Failure, void>> restoreEvent(String eventId);

  // ADMIN/SUPER_ADMIN/MEMBER operations
  Future<Either<Failure, List<ParticipationEntity>>> getEventRegistrations(
    String eventId,
  );
}
