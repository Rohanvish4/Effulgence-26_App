import 'package:effulgence26_mobile_app/features/event/domain/entities/event_params.dart';
import 'package:effulgence26_mobile_app/features/event/domain/repositories/events_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'events_state.dart';

/// Events Cubit for managing events state
/// This cubit handles all event-related state management and user interactions.
/// It communicates with the domain layer (repository) and emits states for the UI to react to.
///
/// FLOW: UI Event → Cubit Method → Repository → DataSource → API → Response → State Emission → UI Update
class EventsCubit extends Cubit<EventsState> {
  // DEPENDENCY: Domain layer repository (business logic interface)
  final EventsRepository eventsRepository;

  EventsCubit({required this.eventsRepository}) : super(const EventsInitial());

  // ===========================================================================
  // PUBLIC EVENTS OPERATIONS (Available to all users)
  // ===========================================================================

  /// Load events with optional filtering
  /// FLOW: UI calls loadEvents() → Repository.getEvents() → Emit EventsLoaded or EventsError
  /// Backend returns ALL events (no pagination implemented)
  /// Load events
  /// FLOW: UI calls loadEvents() → Repository.getEvents() → Emit EventsLoaded or EventsError
  /// Backend returns ALL events
  Future<void> loadEvents({bool refresh = false}) async {
    // STEP 1: Emit loading state (unless refreshing existing data)
    if (refresh || state is! EventsLoaded) {
      emit(const EventsLoading());
    }

    // STEP 2: Call repository (domain layer) - backend returns all events
    final result = await eventsRepository.getEvents();

    // STEP 3: Handle result and emit appropriate state
    result.fold(
      (failure) => emit(EventsError(message: failure.message)), // Left = Error
      (events) => emit(EventsLoaded(events: events)), // Right = Success
    );
  }

  /// Get event details
  Future<void> getEventDetails(String eventId) async {
    emit(const EventDetailsLoading());

    final result = await eventsRepository.getEventById(eventId);

    result.fold(
      (failure) => emit(EventDetailsError(message: failure.message)),
      (event) => emit(EventDetailsLoaded(event: event)),
    );
  }

  /// Register for event
  Future<void> registerForEvent(String eventId) async {
    emit(const EventRegistrationLoading());

    final result = await eventsRepository.registerForEvent(eventId);

    result.fold(
      (failure) => emit(EventRegistrationError(message: failure.message)),
      (_) => emit(
        const EventRegistrationSuccess(
          message: 'Successfully registered for the event!',
        ),
      ),
    );
  }

  /// Create a team for a team event
  Future<void> createTeam({
    required String eventId,
    required String teamName,
    bool isPublic = false,
  }) async {
    emit(const TeamCreationLoading());

    final result = await eventsRepository.createTeam(
      CreateTeamParams(
        eventId: eventId,
        teamName: teamName,
        isPublic: isPublic,
      ),
    );

    result.fold(
      (failure) => emit(TeamCreationError(message: failure.message)),
      (_) => emit(
        const TeamCreationSuccess(
          message: 'Team created successfully! You can now invite members.',
        ),
      ),
    );
  }

  /// Load user's participations
  Future<void> loadMyParticipations() async {
    emit(const MyParticipationsLoading());

    final result = await eventsRepository.getMyParticipations();

    result.fold(
      (failure) => emit(MyParticipationsError(message: failure.message)),
      (participations) =>
          emit(MyParticipationsLoaded(participations: participations)),
    );
  }

  /// Load public teams for a team event
  Future<void> loadPublicTeams(String eventId) async {
    emit(const PublicTeamsLoading());

    final result = await eventsRepository.getPublicTeams(eventId);

    result.fold(
      (failure) => emit(PublicTeamsError(message: failure.message)),
      (teams) => emit(PublicTeamsLoaded(teams: teams)),
    );
  }

  /// Join an existing team
  Future<void> joinTeam({
    required String eventId,
    required String teamId,
  }) async {
    emit(const TeamJoinLoading());

    final result = await eventsRepository.joinTeam(eventId, teamId);

    result.fold(
      (failure) => emit(TeamJoinError(message: failure.message)),
      (_) =>
          emit(const TeamJoinSuccess(message: 'Successfully joined the team!')),
    );
  }

  /// Create a new event (Admin/Super Admin)
  Future<void> createEvent(CreateEventParams params) async {
    emit(const EventCreationLoading());

    final result = await eventsRepository.createEvent(params);

    result.fold(
      (failure) => emit(EventOperationError(message: failure.message)),
      (event) => emit(EventCreated(event: event)),
    );
  }

  /// Update an event (Admin/Super Admin)
  Future<void> updateEvent({
    required String eventId,
    required UpdateEventParams params,
  }) async {
    emit(const EventUpdateLoading());

    final result = await eventsRepository.updateEvent(eventId, params);

    result.fold(
      (failure) => emit(EventOperationError(message: failure.message)),
      (event) => emit(EventUpdated(event: event)),
    );
  }

  /// Delete an event (Admin/Super Admin)
  Future<void> deleteEvent(String eventId) async {
    emit(const EventDeletionLoading());

    final result = await eventsRepository.deleteEvent(eventId);

    result.fold(
      (failure) => emit(EventOperationError(message: failure.message)),
      (_) => emit(const EventDeleted()),
    );
  }

  /// Restore a deleted event (Admin/Super Admin)
  Future<void> restoreEvent(String eventId) async {
    emit(const EventRestorationLoading());

    final result = await eventsRepository.restoreEvent(eventId);

    result.fold(
      (failure) => emit(EventOperationError(message: failure.message)),
      (_) => emit(const EventRestored()),
    );
  }

  /// Load event registrations (Admin/Super Admin/Member)
  Future<void> loadEventRegistrations(String eventId) async {
    emit(const EventRegistrationsLoading());

    final result = await eventsRepository.getEventRegistrations(eventId);

    result.fold(
      (failure) => emit(EventRegistrationsError(message: failure.message)),
      (registrations) =>
          emit(EventRegistrationsLoaded(registrations: registrations)),
    );
  }
}
