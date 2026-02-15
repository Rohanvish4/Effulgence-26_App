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

  // NEW TEAM MANAGEMENT METHODS matched with RemoteDataSource
  
  /// Get my team details for a specific event
  Future<Either<Failure, ParticipationEntity?>> getMyTeam(String eventId);

  /// Get details of a specific team
  Future<Either<Failure, ParticipationEntity>> getTeamDetails(String eventId, String teamId);

  /// Remove a member from the team (Kick)
  Future<Either<Failure, void>> removeTeamMember(String eventId, String teamId, String memberId);

  /// Edit team details
  Future<Either<Failure, void>> editTeam(String eventId, String teamId, String teamName, bool isPublic);

  /// Delete/Disband a team
  Future<Either<Failure, void>> deleteTeam(String eventId, String teamId);

  /// Invite a user to the team by email
  Future<Either<Failure, void>> inviteToTeam(String eventId, String teamId, String email);

  /// Respond to a team invitation
  Future<Either<Failure, void>> respondToInvite(String eventId, String teamId, String inviteId, String action);

  /// Request to join a team
  Future<Either<Failure, void>> requestToJoinTeam(String eventId, String teamId);

  /// Respond to a join request
  Future<Either<Failure, void>> respondToJoinRequest(String eventId, String teamId, String requestId, String action);

  /// Get pending invitations for my team (Creator only)
  Future<Either<Failure, List<dynamic>>> getTeamInvitations(String eventId, String teamId);

  /// Get pending join requests for my team (Creator only)
  Future<Either<Failure, List<dynamic>>> getTeamJoinRequests(String eventId, String teamId);

  /// Get my pending invitations across all events
  Future<Either<Failure, List<dynamic>>> getMyInvitations();

  /// Get my pending join requests across all events
  Future<Either<Failure, List<dynamic>>> getMyJoinRequests();
}
