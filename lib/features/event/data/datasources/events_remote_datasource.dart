import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/event_params.dart';
import '../models/event_model.dart';
import '../models/participation_model.dart';

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
  Future<void> createTeam(String eventId, String teamName);
  Future<List<ParticipationModel>> getMyParticipations();

  // ADMIN/SUPER_ADMIN OPERATIONS
  Future<EventModel> createEvent(CreateEventParams params);
  Future<EventModel> updateEvent(String eventId, UpdateEventParams params);
  Future<void> deleteEvent(String eventId);
  Future<void> restoreEvent(String eventId);

  // ADMIN/SUPER_ADMIN/MEMBER OPERATIONS
  Future<List<ParticipationModel>> getEventRegistrations(String eventId);
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
  Future<void> createTeam(String eventId, String teamName) async {
    await apiClient.post(
      '/events/$eventId/create-team',
      data: {'teamName': teamName},
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

  // ADMIN/SUPER_ADMIN operations
  @override
  Future<EventModel> createEvent(CreateEventParams params) async {
    final response = await apiClient.post(
      '/events/create',
      data: {
        'title': params.title,
        'description': params.description,
        'rules': params.rules,
        'domain': params.domain,
        'eventType': params.eventType,
        'eventVenue': params.eventVenue,
        'eventTime': params.eventTime.toIso8601String(),
        'registrationDeadline': params.registrationDeadline.toIso8601String(),
        'teamConfig': params.teamConfig != null
            ? {
                'minSize': params.teamConfig!.minSize,
                'maxSize': params.teamConfig!.maxSize,
              }
            : null,
      },
    );
    return EventModel.fromJson(response.data['event']);
  }

  @override
  Future<EventModel> updateEvent(
    String eventId,
    UpdateEventParams params,
  ) async {
    final response = await apiClient.patch(
      '/events/$eventId/edit',
      data: {
        if (params.title != null) 'title': params.title,
        if (params.description != null) 'description': params.description,
        if (params.rules != null) 'rules': params.rules,
        if (params.domain != null) 'domain': params.domain,
        if (params.eventType != null) 'eventType': params.eventType,
        if (params.eventVenue != null) 'eventVenue': params.eventVenue,
        if (params.eventTime != null)
          'eventTime': params.eventTime!.toIso8601String(),
        if (params.registrationDeadline != null)
          'registrationDeadline': params.registrationDeadline!
              .toIso8601String(),
        if (params.teamConfig != null)
          'teamConfig': {
            'minSize': params.teamConfig!.minSize,
            'maxSize': params.teamConfig!.maxSize,
          },
      },
    );
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
    final response = await apiClient.get('/events/registrations/$eventId');
    final List<dynamic> data = response.data['registeredParticipation'] ?? [];
    return data.map((json) => ParticipationModel.fromJson(json)).toList();
  }
}
