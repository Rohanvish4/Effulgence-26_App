import 'package:effulgence26_mobile_app/core/demo/demo_data.dart';
import '../models/event_model.dart';
import '../models/participation_model.dart';
import '../models/public_team_model.dart';
import '../../domain/entities/event_params.dart';
import 'events_remote_datasource.dart';

/// Demo implementation of [EventsRemoteDataSource].
/// Returns static mock events; all write operations silently succeed.
class EventsDemoDataSource implements EventsRemoteDataSource {
  @override
  Future<List<EventModel>> getEvents() async => DemoData.mockEvents;

  @override
  Future<EventModel> getEventById(String id) async {
    return DemoData.mockEvents.firstWhere(
      (e) => e.id == id,
      orElse: () => DemoData.mockEvents.first,
    );
  }

  @override
  Future<List<EventModel>> getMyEvents() async => DemoData.myRegisteredEvents;

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    final q = query.toLowerCase();
    return DemoData.mockEvents
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.domain.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<List<ParticipationModel>> getMyParticipations() async =>
      DemoData.myMockParticipations;

  @override
  Future<void> registerForEvent(String eventId) async {}

  @override
  Future<void> unregisterFromEvent(String eventId) async {}

  @override
  Future<void> createTeam(
      String eventId, String teamName, bool isPublic) async {}

  @override
  Future<List<PublicTeamModel>> getPublicTeams(String eventId) async => [];

  @override
  Future<void> joinTeam(String eventId, String teamId) async {}

  @override
  Future<void> leaveTeam(String eventId, String teamId) async {}

  @override
  Future<EventModel> createEvent(CreateEventParams params) async =>
      DemoData.mockEvents.first;

  @override
  Future<EventModel> updateEvent(
          String eventId, UpdateEventParams params) async =>
      DemoData.mockEvents.first;

  @override
  Future<void> deleteEvent(String eventId) async {}

  @override
  Future<void> restoreEvent(String eventId) async {}

  @override
  Future<List<ParticipationModel>> getEventRegistrations(
          String eventId) async =>
      DemoData.myMockParticipations;

  @override
  Future<void> markParticipationAttendance(
      String eventId, String participationId, bool isPresent) async {}

  @override
  Future<Map<String, dynamic>> getParticipantFullDetails(
          String userId) async =>
      {};

  @override
  Future<ParticipationModel?> getMyTeam(String eventId) async => null;

  @override
  Future<ParticipationModel> getTeamDetails(
          String eventId, String teamId) async =>
      DemoData.myMockParticipations.first;

  @override
  Future<void> removeTeamMember(
      String eventId, String teamId, String memberId) async {}

  @override
  Future<void> editTeam(
      String eventId, String teamId, String teamName, bool isPublic) async {}

  @override
  Future<void> deleteTeam(String eventId, String teamId) async {}

  @override
  Future<void> inviteToTeam(
      String eventId, String teamId, String email) async {}

  @override
  Future<void> respondToInvite(String eventId, String teamId, String inviteId,
      String action) async {}

  @override
  Future<void> requestToJoinTeam(String eventId, String teamId) async {}

  @override
  Future<void> respondToJoinRequest(String eventId, String teamId,
      String requestId, String action) async {}

  @override
  Future<List<dynamic>> getTeamInvitations(
          String eventId, String teamId) async =>
      [];

  @override
  Future<List<dynamic>> getTeamJoinRequests(
          String eventId, String teamId) async =>
      [];

  @override
  Future<List<dynamic>> getMyInvitations() async => [];

  @override
  Future<List<dynamic>> getMyJoinRequests() async => [];
}
