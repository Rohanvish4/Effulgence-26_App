import 'package:effulgence26_mobile_app/features/event/domain/entities/event_params.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/participation_entity.dart';
import 'package:effulgence26_mobile_app/features/event/domain/repositories/events_repository.dart';
import 'package:effulgence26_mobile_app/core/utils/debounce_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/analytics_service.dart';
import 'events_state.dart';

/// Events Cubit for managing events state
/// This cubit handles all event-related state management and user interactions.
/// It communicates with the domain layer (repository) and emits states for the UI to react to.
///
/// FLOW: UI Event → Cubit Method → Repository → DataSource → API → Response → State Emission → UI Update
class EventsCubit extends Cubit<EventsState> {
  static const Duration _timelineFallbackDuration = Duration(hours: 1);
  static const Duration _timelineSoonThreshold = Duration(minutes: 30);

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
          timelineItems: _buildTimelineItems(events, DateTime.now()),
          timelineComputedAt: DateTime.now(),
          status: EventsStatus.success,
        ),
      ),
    );
  }

  void refreshTimelineItems({DateTime? at}) {
    final now = at ?? DateTime.now();
    emit(
      state.copyWith(
        timelineItems: _buildTimelineItems(state.events, now),
        timelineComputedAt: now,
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
      (event) {
        AnalyticsService.instance
            .logEventViewed(event.id, event.title)
            .catchError((_) {});
        emit(state.copyWith(isDetailsLoading: false, selectedEvent: event));
      },
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
      (_) {
        final eventName = state.selectedEvent?.title ?? 'Unknown Event';
        AnalyticsService.instance
            .logEventRegistered(eventId, eventName)
            .catchError((_) {});
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Successfully registered for the event!',
          ),
        );
      },
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
      (_) {
        AnalyticsService.instance.logTeamCreated(eventId).catchError((_) {});
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage:
                'Team created successfully! You can now invite members.',
          ),
        );
      },
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
      (_) {
        AnalyticsService.instance
            .logTeamJoined(eventId, teamId)
            .catchError((_) {});
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Successfully joined the team!',
          ),
        );
      },
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
          timelineItems: _buildTimelineItems([
            ...state.events,
            event,
          ], DateTime.now()),
          timelineComputedAt: DateTime.now(),
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
          events:
              state.events.map((e) => e.id == event.id ? event : e).toList(),
          timelineItems: _buildTimelineItems(
            state.events.map((e) => e.id == event.id ? event : e).toList(),
            DateTime.now(),
          ),
          timelineComputedAt: DateTime.now(),
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

  Future<void> markParticipationAttendance({
    required String eventId,
    required String participationId,
    required bool isPresent,
  }) async {
    final result = await eventsRepository.markParticipationAttendance(
      eventId,
      participationId,
      isPresent,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final updatedParticipations =
            state.myParticipations.map((participation) {
              if (participation.id != participationId) {
                return participation;
              }

              return ParticipationEntity(
                id: participation.id,
                eventId: participation.eventId,
                user: participation.user,
                teamMembers: participation.teamMembers,
                teamName: participation.teamName,
                participationType: participation.participationType,
                registeredAt: participation.registeredAt,
                isPresent: isPresent,
                markedPresentAt: isPresent ? DateTime.now() : null,
                rank: participation.rank,
                score: participation.score,
                isQualified: participation.isQualified,
                remarks: participation.remarks,
                isPublic: participation.isPublic,
              );
            }).toList();

        emit(
          state.copyWith(
            myParticipations: updatedParticipations,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getParticipantFullDetails(String userId) async {
    final result = await eventsRepository.getParticipantFullDetails(userId);
    return result.fold((failure) {
      emit(state.copyWith(errorMessage: failure.message));
      return null;
    }, (details) => details);
  }

  /// Debounced search for events (prevents duplicate API calls during rapid typing)

  Future<void> debouncedSearchEvents(String query) async {
    _searchDebouncer.run(() async {
      if (query.isEmpty) {
        emit(
          state.copyWith(
            events: [],
            timelineItems: const [],
            errorMessage: null,
            timelineComputedAt: DateTime.now(),
          ),
        );
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
            timelineItems: _buildTimelineItems(events, DateTime.now()),
            timelineComputedAt: DateTime.now(),
            status: EventsStatus.success,
          ),
        ),
      );
    });
  }

  List<TimelineItemModel> _buildTimelineItems(
    List<EventEntity> events,
    DateTime now,
  ) {
    final sortedEvents = List<EventEntity>.from(events)
      ..sort((a, b) => a.eventTime.compareTo(b.eventTime));

    return sortedEvents
        .map((event) => _resolveTimelineItem(event: event, now: now))
        .toList();
  }

  TimelineItemModel _resolveTimelineItem({
    required EventEntity event,
    required DateTime now,
  }) {
    final normalizedStatus = event.status.trim().toUpperCase();
    final backendResolved = _timelineForKnownBackendStatus(
      event: event,
      now: now,
      normalizedStatus: normalizedStatus,
    );

    if (backendResolved != null) return backendResolved;

    final start = event.eventTime;
    final end = event.endTime ?? start.add(_timelineFallbackDuration);

    if (now.isAfter(end) || now.isAtSameMomentAs(end)) {
      final sinceEnded = now.difference(end);
      final relativeLabel =
          sinceEnded.inMinutes < 1
              ? 'Ended just now'
              : 'Ended ${_formatDurationCompact(sinceEnded)} ago';

      return TimelineItemModel(
        event: event,
        phase: TimelinePhase.ended,
        chipLabel: 'ENDED',
        shortLabel: 'ENDED',
        relativeLabel: relativeLabel,
      );
    }

    if (now.isAfter(start) || now.isAtSameMomentAs(start)) {
      final remaining = end.difference(now);
      final relativeLabel =
          remaining.inMinutes < 1
              ? 'Live now • ending soon'
              : 'Live now • ends in ${_formatDurationCompact(remaining)}';

      return TimelineItemModel(
        event: event,
        phase: TimelinePhase.live,
        chipLabel: 'LIVE',
        shortLabel: 'LIVE',
        relativeLabel: relativeLabel,
      );
    }

    final untilStart = start.difference(now);
    final isSoon = untilStart <= _timelineSoonThreshold;

    return TimelineItemModel(
      event: event,
      phase: isSoon ? TimelinePhase.upcomingSoon : TimelinePhase.upcoming,
      chipLabel: isSoon ? 'STARTING SOON' : 'UPCOMING',
      shortLabel: isSoon ? 'SOON' : 'UPCOMING',
      relativeLabel: 'Starts in ${_formatDurationCompact(untilStart)}',
    );
  }

  TimelineItemModel? _timelineForKnownBackendStatus({
    required EventEntity event,
    required DateTime now,
    required String normalizedStatus,
  }) {
    switch (normalizedStatus) {
      case 'COMPLETED':
        final end =
            event.endTime ?? event.eventTime.add(_timelineFallbackDuration);
        final sinceEnded = now.difference(end);
        final relativeLabel =
            sinceEnded.inMinutes <= 0
                ? 'Ended'
                : 'Ended ${_formatDurationCompact(sinceEnded)} ago';

        return TimelineItemModel(
          event: event,
          phase: TimelinePhase.ended,
          chipLabel: 'ENDED',
          shortLabel: 'ENDED',
          relativeLabel: relativeLabel,
        );

      case 'LIVE':
        final end =
            event.endTime ?? event.eventTime.add(_timelineFallbackDuration);
        final remaining = end.difference(now);
        final relativeLabel =
            remaining.inMinutes <= 0
                ? 'Live • scheduled end passed'
                : 'Live now • ends in ${_formatDurationCompact(remaining)}';

        return TimelineItemModel(
          event: event,
          phase: TimelinePhase.live,
          chipLabel: 'LIVE',
          shortLabel: 'LIVE',
          relativeLabel: relativeLabel,
        );

      case 'UPCOMING':
        final start = event.eventTime;
        final end = event.endTime ?? start.add(_timelineFallbackDuration);

        if (now.isAfter(end) || now.isAtSameMomentAs(end)) {
          final sinceEnded = now.difference(end);
          final relativeLabel =
              sinceEnded.inMinutes <= 0
                  ? 'Ended'
                  : 'Ended ${_formatDurationCompact(sinceEnded)} ago';

          return TimelineItemModel(
            event: event,
            phase: TimelinePhase.ended,
            chipLabel: 'ENDED',
            shortLabel: 'ENDED',
            relativeLabel: relativeLabel,
          );
        }

        if (now.isAfter(start) || now.isAtSameMomentAs(start)) {
          final remaining = end.difference(now);
          final relativeLabel =
              remaining.inMinutes <= 0
                  ? 'Live • scheduled end passed'
                  : 'Live now • ends in ${_formatDurationCompact(remaining)}';

          return TimelineItemModel(
            event: event,
            phase: TimelinePhase.live,
            chipLabel: 'LIVE',
            shortLabel: 'LIVE',
            relativeLabel: relativeLabel,
          );
        }

        final untilStart = start.difference(now);
        final isSoon =
            untilStart <= _timelineSoonThreshold &&
            (untilStart.inMinutes >= 0 || untilStart.inSeconds >= 0);

        final relativeLabel =
            'Starts in ${_formatDurationCompact(untilStart)}';

        return TimelineItemModel(
          event: event,
          phase: isSoon ? TimelinePhase.upcomingSoon : TimelinePhase.upcoming,
          chipLabel: isSoon ? 'STARTING SOON' : 'UPCOMING',
          shortLabel: isSoon ? 'SOON' : 'UPCOMING',
          relativeLabel: relativeLabel,
        );

      default:
        return null;
    }
  }

  String _formatDurationCompact(Duration duration) {
    if (duration.inMinutes < 1) return '<1m';

    final totalMinutes = duration.inMinutes;
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    if (days > 0) {
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
    return '${minutes}m';
  }

  // ===========================================================================
  // TEAM MANAGEMENT METHODS
  // ===========================================================================

  Future<void> getMyTeam(String eventId) async {
    // Check if we already have the team for this event to avoid flicker?
    // For now, simple loading state.
    emit(state.copyWith(isParticipationsLoading: true));

    final result = await eventsRepository.getMyTeam(eventId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (team) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          myTeam: team, // Can be null if not in team
        ),
      ),
    );
  }

  Future<void> removeTeamMember({
    required String eventId,
    required String teamId,
    required String memberId,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.removeTeamMember(
      eventId,
      teamId,
      memberId,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Member removed',
          ),
        );
        // Refresh team details
        getMyTeam(eventId);
      },
    );
  }

  Future<void> editTeam({
    required String eventId,
    required String teamId,
    required String teamName,
    required bool isPublic,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.editTeam(
      eventId,
      teamId,
      teamName,
      isPublic,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Team updated',
          ),
        );
        getMyTeam(eventId);
      },
    );
  }

  Future<void> deleteTeam({
    required String eventId,
    required String teamId,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.deleteTeam(eventId, teamId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Team deleted',
            clearMyTeam: true, // Reset team state properly
          ),
        );
        loadMyParticipations(); // Update global participations list
      },
    );
  }

  Future<void> inviteToTeam({
    required String eventId,
    required String teamId,
    required String email,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.inviteToTeam(eventId, teamId, email);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Invitation sent',
          ),
        );
        // Refresh invitations list for the team
        getTeamInvitations(eventId, teamId);
      },
    );
  }

  Future<void> respondToInvite({
    required String eventId,
    required String teamId,
    required String inviteId,
    required String action,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.respondToInvite(
      eventId,
      teamId,
      inviteId,
      action,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        if (action == 'ACCEPTED') {
          AnalyticsService.instance
              .logTeamJoined(eventId, teamId)
              .catchError((_) {});
        }
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage:
                action == 'ACCEPTED' ? 'Joined team!' : 'Invitation declined',
          ),
        );
        getMyInvitations(); // Refresh my invitations
        if (action == 'ACCEPTED') {
          loadMyParticipations();
        }
      },
    );
  }

  Future<void> requestToJoinTeam({
    required String eventId,
    required String teamId,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.requestToJoinTeam(eventId, teamId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage: 'Join request sent',
          ),
        );
        getMyJoinRequests(); // Refresh my requests
      },
    );
  }

  Future<void> respondToJoinRequest({
    required String eventId,
    required String teamId,
    required String requestId,
    required String action,
  }) async {
    emit(state.copyWith(isOperationLoading: true));
    final result = await eventsRepository.respondToJoinRequest(
      eventId,
      teamId,
      requestId,
      action,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isOperationLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            isOperationLoading: false,
            successMessage:
                action == 'ACCEPTED' ? 'Request accepted' : 'Request rejected',
          ),
        );
        // Refresh requests list for the team
        getTeamJoinRequests(eventId, teamId);
        // Refresh team members if accepted
        if (action == 'ACCEPTED') {
          getMyTeam(eventId);
        }
      },
    );
  }

  Future<void> getTeamInvitations(String eventId, String teamId) async {
    // Silent load or specific loading state, Using operation loading for now to keep it simple
    // or better, just update the list silenty if it's a refresh.
    // For now, let's not block UI with full loading screen, but update state.

    final result = await eventsRepository.getTeamInvitations(eventId, teamId);

    result.fold(
      (failure) => null, // Silently fail or log?
      (invitations) => emit(state.copyWith(teamInvitations: invitations)),
    );
  }

  Future<void> getTeamJoinRequests(String eventId, String teamId) async {
    final result = await eventsRepository.getTeamJoinRequests(eventId, teamId);

    result.fold(
      (failure) => null,
      (requests) => emit(state.copyWith(teamJoinRequests: requests)),
    );
  }

  Future<void> getMyInvitations() async {
    emit(state.copyWith(isParticipationsLoading: true));
    final result = await eventsRepository.getMyInvitations();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (invitations) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          myInvitations: invitations,
        ),
      ),
    );
  }

  Future<void> getMyJoinRequests() async {
    emit(state.copyWith(isParticipationsLoading: true));
    final result = await eventsRepository.getMyJoinRequests();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (requests) => emit(
        state.copyWith(
          isParticipationsLoading: false,
          myJoinRequests: requests,
        ),
      ),
    );
  }

  /// Clean up resources (call in UI dispose method)
  void cleanup() {
    _searchDebouncer.dispose();
  }

  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    return super.close();
  }
}
