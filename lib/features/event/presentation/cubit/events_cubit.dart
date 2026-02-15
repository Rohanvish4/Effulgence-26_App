import 'package:effulgence26_mobile_app/features/event/domain/entities/event_params.dart';
import 'package:effulgence26_mobile_app/features/event/domain/repositories/events_repository.dart';
import 'package:effulgence26_mobile_app/core/utils/debounce_helper.dart';
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
  
  // Debouncer for search operations (prevents duplicate API calls)
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);

  EventsCubit(this.eventsRepository) : super(const EventsState());

  Future<void> loadEvents({bool refresh = false}) async {
    if (refresh || state.events.isEmpty) {
      emit(
        state.copyWith(
          isEventsLoading: true,
          errorMessage: null,
          successMessage: null,
        ),
      );
    }

    final result = await eventsRepository.getEvents();

    result.fold(
      (failure) => emit(
        state.copyWith(isEventsLoading: false, errorMessage: failure.message),
      ),
      (events) => emit(
        state.copyWith(
          isEventsLoading: false,
          events: events,
          status: EventsStatus.success,
        ),
      ),
    );
  }

  Future<void> getEventDetails(String eventId) async {
    emit(
      state.copyWith(
        isDetailsLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.getEventById(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(isDetailsLoading: false, errorMessage: failure.message),
      ),
      (event) =>
          emit(state.copyWith(isDetailsLoading: false, selectedEvent: event)),
    );
  }

  /// Register for event
  Future<void> registerForEvent(String eventId) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.registerForEvent(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Successfully registered for the event!',
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
    emit(
      state.copyWith(
        isOperationLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.createTeam(
      CreateTeamParams(
        eventId: eventId,
        teamName: teamName,
        isPublic: isPublic,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage:
              'Team created successfully! You can now invite members.',
        ),
      ),
    );
  }

  /// Load user's participations
  Future<void> loadMyParticipations() async {
    emit(
      state.copyWith(
        isParticipationsLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.getMyParticipations();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (participations) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          myParticipations: participations,
        ),
      ),
    );
  }

  /// Load public teams for a team event
  Future<void> loadPublicTeams(String eventId) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.getPublicTeams(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (teams) =>
          emit(state.copyWith(isOperationLoading: false, publicTeams: teams)),
    );
  }

  /// Join an existing team
  Future<void> joinTeam({
    required String eventId,
    required String teamId,
  }) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.joinTeam(eventId, teamId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Successfully joined the team!',
        ),
      ),
    );
  }

  /// Leave a team
  Future<void> leaveTeam({
    required String eventId,
    required String teamId,
  }) async {
    emit(
      state.copyWith(
        isOperationLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    final result = await eventsRepository.leaveTeam(eventId, teamId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Success - emit success message and reload participations
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Left team successfully',
          ),
        );
        // Auto-refresh participations to update UI
        loadMyParticipations();
      },
    );
  }

  /// Create a new event (Admin/Super Admin)
  Future<void> createEvent(CreateEventParams params) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.createEvent(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (event) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Event created',
          events: [...state.events, event],
        ),
      ),
    );
  }

  /// Update an event (Admin/Super Admin)
  Future<void> updateEvent({
    required String eventId,
    required UpdateEventParams params,
  }) async {
    emit(state.copyWith(isOperationLoading: true));

    final result = await eventsRepository.updateEvent(eventId, params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (event) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Event updated',
          events: [...state.events, event],
        ),
      ),
    );
  }

  /// Delete an event (Admin/Super Admin)
  Future<void> deleteEvent(String eventId) async {
    emit(state.copyWith(isOperationLoading: true));

    final result = await eventsRepository.deleteEvent(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Event deleted',
        ),
      ),
    );
  }

  /// Restore a deleted event (Admin/Super Admin)
  Future<void> restoreEvent(String eventId) async {
    emit(state.copyWith(isOperationLoading: true));

    final result = await eventsRepository.restoreEvent(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: 'Event restored',
        ),
      ),
    );
  }

  /// Load event registrations (Admin/Super Admin/Member)
  Future<void> loadEventRegistrations(String eventId) async {
    emit(state.copyWith(isOperationLoading: true));

    final result = await eventsRepository.getEventRegistrations(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (registrations) => emit(
        state.copyWith(
          isOperationLoading: false,
          successMessage: null,
          myParticipations: registrations,
        ),
      ),
    );
  }

  /// Debounced search for events (prevents duplicate API calls during rapid typing)

  Future<void> debouncedSearchEvents(String query) async {
    _searchDebouncer.run(() async {
      if (query.isEmpty) {
        emit(state.copyWith(events: [], errorMessage: null));
        return;
      }

      emit(
        state.copyWith(
          isEventsLoading: true,
          errorMessage: null,
          successMessage: null,
        ),
      );

      final result = await eventsRepository.searchEvents(query);

      result.fold(
        (failure) => emit(
          state.copyWith(isEventsLoading: false, errorMessage: failure.message),
        ),
        (events) => emit(
          state.copyWith(
            isEventsLoading: false,
            events: events,
            status: EventsStatus.success,
          ),
        ),
      );
    });
  }

  /// Clean up resources (call in UI dispose method)
  void cleanup() {
    _searchDebouncer.dispose();
  }
}