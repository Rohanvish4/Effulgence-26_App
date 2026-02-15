import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/event_params.dart';
import '../../domain/entities/participation_entity.dart';
import '../../domain/entities/public_team_entity.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_datasource.dart';

/// Events repository implementation
/// This class implements the EventsRepository interface from the domain layer.
/// It acts as a bridge between the domain layer (business logic) and data layer (API calls).
///
/// FLOW: Domain UseCase → Repository Interface → RepositoryImpl → DataSource → API
class EventsRepositoryImpl implements EventsRepository {
  // DEPENDENCIES: Injected via constructor (Dependency Inversion Principle)
  final EventsRemoteDataSource remoteDataSource; // API calls
  final NetworkInfo networkInfo; // Network connectivity checks

  EventsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ===========================================================================
  // PUBLIC EVENTS OPERATIONS (Available to all users)
  // ===========================================================================

  /// Get all events with optional filtering
  /// FLOW: UI → Cubit.loadEvents() → EventsRepository.getEvents() → EventsRepositoryImpl.getEvents() → RemoteDataSource.getEvents() → API
  /// Backend returns ALL events (no pagination implemented)
  @override
  Future<Either<Failure, List<EventEntity>>> getEvents() async {
    // STEP 1: Check network connectivity before making API calls
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure()); // Return network error if offline
    }

    try {
      // STEP 2: Call remote data source (API) - backend returns all events
      final events = await remoteDataSource.getEvents();

      // STEP 3: Return success with data
      return Right(events); // Either.Right = Success
    } on ServerException catch (e) {
      // STEP 4: Handle API errors and convert to domain failures
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // STEP 5: Handle unexpected errors
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> getEventById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final event = await remoteDataSource.getEventById(id);
      return Right(event);
    } on NotFoundException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> registerForEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.registerForEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterFromEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.unregisterFromEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> getMyEvents() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final events = await remoteDataSource.getMyEvents();
      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EventEntity>>> searchEvents(String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final events = await remoteDataSource.searchEvents(query);
      return Right(events);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // USER operations
  @override
  Future<Either<Failure, void>> createTeam(CreateTeamParams params) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.createTeam(
        params.eventId,
        params.teamName,
        params.isPublic,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParticipationEntity>>>
  getMyParticipations() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final participations = await remoteDataSource.getMyParticipations();
      return Right(participations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PublicTeamEntity>>> getPublicTeams(
    String eventId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final teams = await remoteDataSource.getPublicTeams(eventId);
      return Right(teams);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> joinTeam(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.joinTeam(eventId, teamId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveTeam(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.leaveTeam(eventId, teamId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ADMIN/SUPER_ADMIN operations
  @override
  Future<Either<Failure, EventEntity>> createEvent(
    CreateEventParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final event = await remoteDataSource.createEvent(params);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent(
    String eventId,
    UpdateEventParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final event = await remoteDataSource.updateEvent(eventId, params);
      return Right(event);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreEvent(String eventId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.restoreEvent(eventId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ADMIN/SUPER_ADMIN/MEMBER operations
  @override
  Future<Either<Failure, List<ParticipationEntity>>> getEventRegistrations(
    String eventId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final registrations = await remoteDataSource.getEventRegistrations(
        eventId,
      );
      return Right(registrations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // TEAM MANAGEMENT IMPLEMENTATION

  @override
  Future<Either<Failure, ParticipationEntity?>> getMyTeam(String eventId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final team = await remoteDataSource.getMyTeam(eventId);
      return Right(team);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParticipationEntity>> getTeamDetails(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performRequest(() => remoteDataSource.getTeamDetails(eventId, teamId));
  }

  @override
  Future<Either<Failure, void>> removeTeamMember(String eventId, String teamId, String memberId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.removeTeamMember(eventId, teamId, memberId));
  }

  @override
  Future<Either<Failure, void>> editTeam(String eventId, String teamId, String teamName, bool isPublic) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.editTeam(eventId, teamId, teamName, isPublic));
  }

  @override
  Future<Either<Failure, void>> deleteTeam(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.deleteTeam(eventId, teamId));
  }

  @override
  Future<Either<Failure, void>> inviteToTeam(String eventId, String teamId, String email) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.inviteToTeam(eventId, teamId, email));
  }

  @override
  Future<Either<Failure, void>> respondToInvite(String eventId, String teamId, String inviteId, String action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.respondToInvite(eventId, teamId, inviteId, action));
  }

  @override
  Future<Either<Failure, void>> requestToJoinTeam(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.requestToJoinTeam(eventId, teamId));
  }

  @override
  Future<Either<Failure, void>> respondToJoinRequest(String eventId, String teamId, String requestId, String action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performVoidRequest(() => remoteDataSource.respondToJoinRequest(eventId, teamId, requestId, action));
  }

  @override
  Future<Either<Failure, List<dynamic>>> getTeamInvitations(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performRequest(() => remoteDataSource.getTeamInvitations(eventId, teamId));
  }

  @override
  Future<Either<Failure, List<dynamic>>> getTeamJoinRequests(String eventId, String teamId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performRequest(() => remoteDataSource.getTeamJoinRequests(eventId, teamId));
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMyInvitations() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performRequest(() => remoteDataSource.getMyInvitations());
  }

  @override
  Future<Either<Failure, List<dynamic>>> getMyJoinRequests() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return _performRequest(() => remoteDataSource.getMyJoinRequests());
  }

  // Helper methods to reduce boilerplate
  Future<Either<Failure, T>> _performRequest<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> _performVoidRequest(Future<void> Function() request) async {
    try {
      await request();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
