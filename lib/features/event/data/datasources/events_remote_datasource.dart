import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/event_params.dart';
import '../models/event_model.dart';
import '../models/participation_model.dart';
import '../models/public_team_model.dart';

import '../../../auth/data/datasources/auth_local_datasource.dart';

/// Events remote data source interface
/// Defines the contract for API communication related to events
abstract class EventsRemoteDataSource {
  // PUBLIC OPERATIONS (All users)
  Future<List<EventModel>> getEvents();

  Future<EventModel> getEventById(String id);
  Future<void> registerForEvent(String eventId);
  Future<void> unregisterFromEvent(String eventId);
  Future<List<EventModel>> getMyEvents();
  Future<List<EventModel>> searchEvents(String query);

  // USER OPERATIONS (Authenticated users)
  Future<void> createTeam(String eventId, String teamName, bool isPublic);
  Future<List<ParticipationModel>> getMyParticipations();

  /// Get public teams for a team event
  Future<List<PublicTeamModel>> getPublicTeams(String eventId);

  /// Join an existing team
  Future<void> joinTeam(String eventId, String teamId);

  /// Leave a team
  Future<void> leaveTeam(String eventId, String teamId);

  // ADMIN/SUPER_ADMIN OPERATIONS
  Future<EventModel> createEvent(CreateEventParams params);
  Future<EventModel> updateEvent(String eventId, UpdateEventParams params);
  Future<void> deleteEvent(String eventId);
  Future<void> restoreEvent(String eventId);

  // ADMIN/SUPER_ADMIN/MEMBER OPERATIONS
  Future<List<ParticipationModel>> getEventRegistrations(String eventId);

  // NEW TEAM MANAGEMENT METHODS
  Future<ParticipationModel?> getMyTeam(String eventId);
  Future<ParticipationModel> getTeamDetails(String eventId, String teamId);
  Future<void> removeTeamMember(String eventId, String teamId, String memberId);
  Future<void> editTeam(String eventId, String teamId, String teamName, bool isPublic);
  Future<void> deleteTeam(String eventId, String teamId);
  Future<void> inviteToTeam(String eventId, String teamId, String email);
  Future<void> respondToInvite(String eventId, String teamId, String inviteId, String action);
  Future<void> requestToJoinTeam(String eventId, String teamId);
  Future<void> respondToJoinRequest(String eventId, String teamId, String requestId, String action);
  Future<List<dynamic>> getTeamInvitations(String eventId, String teamId);
  Future<List<dynamic>> getTeamJoinRequests(String eventId, String teamId);
  Future<List<dynamic>> getMyInvitations();
  Future<List<dynamic>> getMyJoinRequests();
}

/// Events remote data source implementation
/// Handles all HTTP communication with the backend API for events.
/// Converts JSON responses to domain models and throws exceptions for error handling.
///
/// FLOW: RepositoryImpl → RemoteDataSource → ApiClient → HTTP Request → Backend API
class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  // DEPENDENCY: HTTP client for API communication
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  EventsRemoteDataSourceImpl({
    required this.apiClient,
    required this.authLocalDataSource,
  });

  // ===========================================================================
  // PUBLIC EVENTS OPERATIONS (No authentication required)
  // ===========================================================================

  /// Get all events from API
  /// API: GET /events (backend returns all events)
  @override
  Future<List<EventModel>> getEvents() async {
    // Make HTTP GET request to /events endpoint
    final response = await apiClient.get(ApiConstants.events);

    // Parse JSON response and convert to EventModel objects
    final List<dynamic> data = response.data['data'] ?? response.data ?? [];
    return data.map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<EventModel> getEventById(String id) async {
    final response = await apiClient.get('${ApiConstants.eventDetails}$id');
    return EventModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> registerForEvent(String eventId) async {
    await apiClient.post(
      ApiConstants.registerEvent,
      data: {'eventId': eventId, 'participationType': 'INDIVIDUAL'},
    );
  }

  @override
  Future<void> unregisterFromEvent(String eventId) async {
    await apiClient.delete('${ApiConstants.registerEvent}/$eventId');
  }

  @override
  Future<List<EventModel>> getMyEvents() async {
    final response = await apiClient.get('${ApiConstants.events}/my');
    final List<dynamic> data = response.data['data'] ?? response.data ?? [];
    return data.map((json) => EventModel.fromJson(json)).toList();
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    final response = await apiClient.get(
      ApiConstants.events,
      queryParameters: {'search': query},
    );
    final List<dynamic> data = response.data['data'] ?? response.data ?? [];
    return data.map((json) => EventModel.fromJson(json)).toList();
  }

  // USER operations
  @override
  Future<void> createTeam(
    String eventId,
    String teamName,
    bool isPublic,
  ) async {
    await apiClient.post(
      '/events/$eventId/create-team',
      data: {'teamName': teamName, 'isPublic': isPublic},
    );
  }

  @override
  Future<List<ParticipationModel>> getMyParticipations() async {
    final user = await authLocalDataSource.getUser();
    if (user == null) {
      // Return empty list or throw exception based on requirement
      return [];
    }

    final response = await apiClient.get('/user/${user.id}/registered-events');
    final List<dynamic> data = response.data['data'] ?? response.data ?? [];
    return data.map((json) => ParticipationModel.fromJson(json)).toList();
  }

  // PUBLIC TEAM OPERATIONS
  @override
  Future<List<PublicTeamModel>> getPublicTeams(String eventId) async {
    final response = await apiClient.get('/events/$eventId/get-public-teams');

    // Backend returns: { data: [...] } or { message: "No teams...", data: [] }
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => PublicTeamModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> joinTeam(String eventId, String teamId) async {
    await apiClient.post('/events/$eventId/team/$teamId');
  }

  @override
  Future<void> leaveTeam(String eventId, String teamId) async {
    await apiClient.post('/events/$eventId/team/$teamId/leave');
  }

  // ADMIN/SUPER_ADMIN operations
  @override
  Future<EventModel> createEvent(CreateEventParams params) async {
    final Map<String, dynamic> data = {
      'title': params.title,
      'description': params.description,
      'rules': params.rules,
      'domain': params.domain,
      'eventType': params.eventType,
      'eventVenue': params.eventVenue,
      'eventTime': params.eventTime.toUtc().toIso8601String(),
      'endTime': params.endTime.toUtc().toIso8601String(),
      'registrationDeadline': params.registrationDeadline
          .toUtc()
          .toIso8601String(),
      'eventRound': params.eventRound,
    };

    if (params.teamConfig != null) {
      data['teamConfig'] = {
        'minSize': params.teamConfig!.minSize,
        'maxSize': params.teamConfig!.maxSize,
      };
    }

    final response = await apiClient.post('/events/create', data: data);
    return EventModel.fromJson(response.data['event']);
  }

  @override
  Future<EventModel> updateEvent(
    String eventId,
    UpdateEventParams params,
  ) async {
    final Map<String, dynamic> data = {};
    if (params.title != null) data['title'] = params.title;
    if (params.description != null) data['description'] = params.description;
    if (params.rules != null) data['rules'] = params.rules;
    if (params.domain != null) data['domain'] = params.domain;
    if (params.eventType != null) data['eventType'] = params.eventType;
    if (params.eventVenue != null) data['eventVenue'] = params.eventVenue;
    if (params.eventTime != null) {
      data['eventTime'] = params.eventTime!.toUtc().toIso8601String();
    }
    if (params.endTime != null) {
      data['endTime'] = params.endTime!.toUtc().toIso8601String();
    }
    if (params.registrationDeadline != null) {
      data['registrationDeadline'] = params.registrationDeadline!
          .toUtc()
          .toIso8601String();
    }
    if (params.eventRound != null) data['eventRound'] = params.eventRound;
    if (params.teamConfig != null) {
      data['teamConfig'] = {
        'minSize': params.teamConfig!.minSize,
        'maxSize': params.teamConfig!.maxSize,
      };
    }


    final response = await apiClient.patch('/events/$eventId/edit', data: data);
    return EventModel.fromJson(response.data['event']);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await apiClient.patch('/events/$eventId/delete');
  }

  @override
  Future<void> restoreEvent(String eventId) async {
    await apiClient.patch('/events/$eventId/restore-event');
  }

  // ADMIN/SUPER_ADMIN/MEMBER operations
  @override
  Future<List<ParticipationModel>> getEventRegistrations(String eventId) async {
    final response = await apiClient.get('/events/$eventId/registrations');
    final List<dynamic> data = response.data['registeredParticipation'] ?? [];
    return data.map((json) => ParticipationModel.fromJson(json)).toList();
  }

  // TEAM MANAGEMENT IMPLEMENTATION
  @override
  Future<ParticipationModel?> getMyTeam(String eventId) async {
    try {
      final response = await apiClient.get('/events/$eventId/my-team');
      final data = response.data['data'];
      if (data == null) return null;
      return ParticipationModel.fromJson(data);
    } catch (e) {
      if (e.toString().contains('404')) {
        return null; // Not in a team
      }
      rethrow;
    }
  }

  @override
  Future<ParticipationModel> getTeamDetails(String eventId, String teamId) async {
    final response = await apiClient.get('/events/$eventId/team/$teamId');
    return ParticipationModel.fromJson(response.data['data']);
  }

  @override
  Future<void> removeTeamMember(String eventId, String teamId, String memberId) async {
    await apiClient.delete('/events/$eventId/team/$teamId/member/$memberId');
  }

  @override
  Future<void> editTeam(
    String eventId,
    String teamId,
    String teamName,
    bool isPublic,
  ) async {
    await apiClient.patch(
      '/events/$eventId/team/$teamId',
      data: {'teamName': teamName, 'isPublic': isPublic},
    );
  }

  @override
  Future<void> deleteTeam(String eventId, String teamId) async {
    await apiClient.delete('/events/$eventId/team/$teamId');
  }

  @override
  Future<void> inviteToTeam(
    String eventId,
    String teamId,
    String email,
  ) async {
    await apiClient.post(
      '/events/$eventId/team/$teamId/invite',
      data: {'email': email},
    );
  }

  @override
  Future<void> respondToInvite(
    String eventId,
    String teamId,
    String inviteId,
    String action,
  ) async {
    await apiClient.post(
      '/events/$eventId/team/$teamId/invite/$inviteId/respond',
      data: {'action': action},
    );
  }

  @override
  Future<void> requestToJoinTeam(String eventId, String teamId) async {
    await apiClient.post('/events/$eventId/team/$teamId/request');
  }

  @override
  Future<void> respondToJoinRequest(
    String eventId,
    String teamId,
    String requestId,
    String action,
  ) async {
    await apiClient.post(
      '/events/$eventId/team/$teamId/request/$requestId/respond',
      data: {'action': action},
    );
  }

  @override
  Future<List<dynamic>> getTeamInvitations(String eventId, String teamId) async {
    final response = await apiClient.get('/events/$eventId/team/$teamId/invitations');
    return response.data['data'] ?? [];
  }

  @override
  Future<List<dynamic>> getTeamJoinRequests(String eventId, String teamId) async {
    final response = await apiClient.get('/events/$eventId/team/$teamId/requests');
    return response.data['data'] ?? [];
  }

  @override
  Future<List<dynamic>> getMyInvitations() async {
    final response = await apiClient.get('/events/my-invitations');
    return response.data['data'] ?? [];
  }

  @override
  Future<List<dynamic>> getMyJoinRequests() async {
    final response = await apiClient.get('/events/my-join-requests');
    return response.data['data'] ?? [];
  }
}
