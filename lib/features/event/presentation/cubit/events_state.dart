import '../../domain/entities/event_entity.dart';
import '../../domain/entities/participation_entity.dart';
import '../../domain/entities/public_team_entity.dart';

/// Events state hierarchy
/// All states extend EventsState and implement Equatable for comparison.
/// UI components listen to these states and rebuild accordingly.
///
/// STATE FLOW: Initial → Loading → Loaded/Error
/// Each operation has its own loading/success/error states
abstract class EventsState {
  const EventsState();
}

// ===========================================================================
// BASIC EVENTS STATES (List operations)
// ===========================================================================

/// Initial state when cubit is first created
class EventsInitial extends EventsState {
  const EventsInitial();
}

/// Loading state while fetching events list
class EventsLoading extends EventsState {
  const EventsLoading();
}

/// Success state with loaded events data
class EventsLoaded extends EventsState {
  final List<EventEntity> events; // The events data

  const EventsLoaded({required this.events});

  // Helper method to create updated state (immutable)
  EventsLoaded copyWith({List<EventEntity>? events}) {
    return EventsLoaded(events: events ?? this.events);
  }
}

/// Error state when events loading fails
class EventsError extends EventsState {
  final String message; // Error message to display to user

  const EventsError({required this.message});
}

// ===========================================================================
// EVENT DETAILS STATES (Single event operations)
// ===========================================================================

/// Loading state while fetching single event details
class EventDetailsLoading extends EventsState {
  const EventDetailsLoading();
}

/// Success state with single event data
class EventDetailsLoaded extends EventsState {
  final EventEntity event; // The detailed event data

  const EventDetailsLoaded({required this.event});
}

/// Error state when event details loading fails
class EventDetailsError extends EventsState {
  final String message;

  const EventDetailsError({required this.message});
}

/// Event registration states
class EventRegistrationLoading extends EventsState {
  const EventRegistrationLoading();
}

class EventRegistrationSuccess extends EventsState {
  final String message;

  const EventRegistrationSuccess({required this.message});
}

class EventRegistrationError extends EventsState {
  final String message;

  const EventRegistrationError({required this.message});
}

/// Team creation states
class TeamCreationLoading extends EventsState {
  const TeamCreationLoading();
}

class TeamCreationSuccess extends EventsState {
  final String message;

  const TeamCreationSuccess({required this.message});
}

class TeamCreationError extends EventsState {
  final String message;

  const TeamCreationError({required this.message});
}

/// My participations states
class MyParticipationsLoading extends EventsState {
  const MyParticipationsLoading();
}

class MyParticipationsLoaded extends EventsState {
  final List<ParticipationEntity> participations;

  const MyParticipationsLoaded({required this.participations});
}

class MyParticipationsError extends EventsState {
  final String message;

  const MyParticipationsError({required this.message});
}

/// Event registrations states (Admin/Member)
class EventRegistrationsLoading extends EventsState {
  const EventRegistrationsLoading();
}

class EventRegistrationsLoaded extends EventsState {
  final List<ParticipationEntity> registrations;

  const EventRegistrationsLoaded({required this.registrations});
}

class EventRegistrationsError extends EventsState {
  final String message;

  const EventRegistrationsError({required this.message});
}

/// Admin event management states
class EventCreationLoading extends EventsState {
  const EventCreationLoading();
}

class EventCreationSuccess extends EventsState {
  final EventEntity event;
  final String message;

  const EventCreationSuccess({required this.event, required this.message});
}

class EventCreationError extends EventsState {
  final String message;

  const EventCreationError({required this.message});
}

class EventUpdateLoading extends EventsState {
  const EventUpdateLoading();
}

class EventUpdateSuccess extends EventsState {
  final EventEntity event;
  final String message;

  const EventUpdateSuccess({required this.event, required this.message});
}

class EventUpdateError extends EventsState {
  final String message;

  const EventUpdateError({required this.message});
}

class EventDeletionLoading extends EventsState {
  const EventDeletionLoading();
}

class EventDeletionSuccess extends EventsState {
  final String message;

  const EventDeletionSuccess({required this.message});
}

class EventDeletionError extends EventsState {
  final String message;

  const EventDeletionError({required this.message});
}

class EventRestorationLoading extends EventsState {
  const EventRestorationLoading();
}

class EventRestorationSuccess extends EventsState {
  final String message;

  const EventRestorationSuccess({required this.message});
}

class EventRestorationError extends EventsState {
  final String message;

  const EventRestorationError({required this.message});
}

// ===========================================================================
// SIMPLIFIED ADMIN OPERATION STATES (For AdminEventsPage)
// ===========================================================================

/// Unified successful event creation state
class EventCreated extends EventsState {
  final EventEntity event;

  const EventCreated({required this.event});
}

/// Unified successful event update state
class EventUpdated extends EventsState {
  final EventEntity event;

  const EventUpdated({required this.event});
}

/// Unified successful event deletion state
class EventDeleted extends EventsState {
  const EventDeleted();
}

/// Unified successful event restoration state
class EventRestored extends EventsState {
  const EventRestored();
}

// ===========================================================================
// PUBLIC TEAMS STATES (Browsing teams for team events)
// ===========================================================================

/// Loading state while fetching public teams
class PublicTeamsLoading extends EventsState {
  const PublicTeamsLoading();
}

/// Loaded state with public teams data
class PublicTeamsLoaded extends EventsState {
  final List<PublicTeamEntity> teams;

  const PublicTeamsLoaded({required this.teams});
}

/// Error state when public teams loading fails
class PublicTeamsError extends EventsState {
  final String message;

  const PublicTeamsError({required this.message});
}

// ===========================================================================
// TEAM JOIN STATES (Joining existing teams)
// ===========================================================================

/// Loading state while joining team
class TeamJoinLoading extends EventsState {
  const TeamJoinLoading();
}

/// Success state after joining team
class TeamJoinSuccess extends EventsState {
  final String message;

  const TeamJoinSuccess({required this.message});
}

/// Error state when joining team fails
class TeamJoinError extends EventsState {
  final String message;

  const TeamJoinError({required this.message});
}

/// Unified error state for admin operations
class EventOperationError extends EventsState {
  final String message;

  const EventOperationError({required this.message});
}
