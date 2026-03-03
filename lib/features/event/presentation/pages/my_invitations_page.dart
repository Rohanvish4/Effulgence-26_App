import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

class MyInvitationsPage extends StatefulWidget {
  const MyInvitationsPage({super.key});

  @override
  State<MyInvitationsPage> createState() => _MyInvitationsPageState();
}

class _MyInvitationsPageState extends State<MyInvitationsPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final cubit = context.read<EventsCubit>();
    cubit.getMyInvitations();
    cubit.getMyJoinRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('My Team Activity'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<EventsCubit, EventsState>(
        listener: (context, state) {
           if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error, duration: const Duration(milliseconds: 1500)),
            );
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success, duration: const Duration(milliseconds: 1500)),
            );
            // Refresh after accept/decline
            _loadData();
          }
        },
        builder: (context, state) {
          if (state.isParticipationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final invitations = state.myInvitations;
          final requests = state.myJoinRequests;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Invitations Received'),
                  const SizedBox(height: AppSpacing.md),
                  if (invitations.isEmpty)
                     const Text('No pending invitations', style: TextStyle(color: Colors.white54)),
                  ...invitations.map((teamData) => _buildTeamInvitationsGroup(context, teamData)),

                  const SizedBox(height: AppSpacing.xl),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionTitle('Sent Requests'),
                  const SizedBox(height: AppSpacing.md),
                   if (requests.isEmpty)
                     const Text('No sent requests', style: TextStyle(color: Colors.white54)),
                  ...requests.map((teamData) => _buildTeamRequestsGroup(context, teamData)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  /// Build invitation cards for a team group
  /// Backend format: { teamId, teamName, event: { _id, title, ... }, invitations: [{ _id, user, invitedBy, status }] }
  Widget _buildTeamInvitationsGroup(BuildContext context, dynamic teamData) {
    final teamId = teamData['teamId']?.toString() ?? '';
    final teamName = teamData['teamName'] ?? 'Unknown Team';
    final event = teamData['event'] ?? {};
    final eventTitle = event['title'] ?? 'Unknown Event';
    final eventId = event['_id']?.toString() ?? '';
    final List<dynamic> invitations = teamData['invitations'] ?? [];

    return Column(
      children: invitations.map((invite) {
        final inviteId = invite['_id']?.toString() ?? '';
        final invitedBy = invite['invitedBy'];
        final inviterName = invitedBy is Map ? (invitedBy['name'] ?? 'Someone') : 'Someone';

        return Card(
          color: AppColors.bgSecondary.withValues(alpha: 0.5),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invited to: $teamName', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Event: $eventTitle', style: TextStyle(color: AppColors.textMuted)),
                Text('By: $inviterName', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                         context.read<EventsCubit>().respondToInvite(
                           eventId: eventId,
                           teamId: teamId,
                           inviteId: inviteId,
                           action: 'DECLINED',
                         );
                      },
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        context.read<EventsCubit>().respondToInvite(
                           eventId: eventId,
                           teamId: teamId,
                           inviteId: inviteId,
                           action: 'ACCEPTED',
                         );
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build request cards for a team group
  /// Backend format: { teamId, teamName, event: { _id, title, ... }, joinRequests: [{ _id, user, status }] }
  Widget _buildTeamRequestsGroup(BuildContext context, dynamic teamData) {
    final teamName = teamData['teamName'] ?? 'Unknown Team';
    final event = teamData['event'] ?? {};
    final eventTitle = event['title'] ?? 'Unknown Event';
    final List<dynamic> joinRequests = teamData['joinRequests'] ?? [];

    return Column(
      children: joinRequests.map((req) {
        final status = req['status'] ?? 'PENDING';

        return Card(
          color: AppColors.bgSecondary.withValues(alpha: 0.3),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            title: Text('Request to join: $teamName', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Event: $eventTitle', style: TextStyle(color: AppColors.textMuted)),
            trailing: Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: status == 'PENDING' ? Colors.orange.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                 borderRadius: BorderRadius.circular(4),
                 border: Border.all(color: status == 'PENDING' ? Colors.orange : Colors.grey),
               ),
               child: Text(status, style: TextStyle(color: status == 'PENDING' ? Colors.orange : Colors.grey, fontSize: 12)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
