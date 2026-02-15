import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../components/components.dart';
import '../../domain/entities/participation_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class TeamManagementPage extends StatefulWidget {
  final String eventId;

  const TeamManagementPage({super.key, required this.eventId});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  final _teamNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final cubit = context.read<EventsCubit>();
    cubit.getMyTeam(widget.eventId).then((_) {
      // After team loads, fetch join requests if we have a team
      final team = cubit.state.myTeam;
      if (team != null) {
        cubit.getTeamJoinRequests(widget.eventId, team.id);
      }
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Manage Team'),
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
          }
          if (state.myTeam == null && !state.isParticipationsLoading && state.errorMessage == null) {
            // If user left team or team deleted, pop back
            // Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state.isParticipationsLoading && state.myTeam == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final team = state.myTeam;
          if (team == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('No team found.', style: TextStyle(color: Colors.white)),
                   const SizedBox(height: 20),
                   AppButton(text: 'Refresh', onPressed: _loadData),
                ],
              ),
            );
          }

          final currentUserId = context.read<AuthCubit>().currentUser?.id ?? '';
          // Leader is always teamMembers[0] — backend has no separate 'user' field
          final isLeader = team.teamMembers.isNotEmpty && team.teamMembers[0].id == currentUserId;

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// ... (I need to match strict context, so I'll do partial replacements)
                  // Team Header
                  _buildTeamHeader(context, team, isLeader),
                  const SizedBox(height: AppSpacing.xl),

                  // Members List
                  _buildSectionTitle('Members (${team.teamMembers.length})'),
                  const SizedBox(height: AppSpacing.md),
                  ...team.teamMembers.map((member) => _buildMemberTile(context, team, member, isLeader, currentUserId)),

                  const SizedBox(height: AppSpacing.xl),

                  // Invite Member (Leader only)
                  if (isLeader) ...[
                     _buildLinkInviteSection(context, team),
                     const SizedBox(height: AppSpacing.xl),
                  ],

                  // Join Requests (Leader only)
                  if (isLeader) ...[
                    _buildJoinRequestsSection(context, widget.eventId, team.id),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Actions
                  if (isLeader)
                    AppButton(
                      text: 'DELETE TEAM',
                      backgroundColor: AppColors.error,
                      isFullWidth: true,
                      onPressed: () => _confirmDeleteTeam(context, team.id),
                    )
                  else
                    AppButton(
                      text: 'LEAVE TEAM',
                      backgroundColor: AppColors.error,
                      isFullWidth: true,
                      onPressed: () => _confirmLeaveTeam(context, team.id),
                    ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamHeader(BuildContext context, ParticipationEntity team, bool isLeader) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName ?? 'Unnamed Team',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Team ID: ${team.id.substring(0, 8)}...',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (isLeader)
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  onPressed: () => _showEditTeamDialog(context, team),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, ParticipationEntity team, ParticipationUser member, bool isLeader, String currentUserId) {
    final isMe = member.id == currentUserId;
    return Card(
      color: AppColors.bgSecondary.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.2),
          child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary)),
        ),
        title: Text(isMe ? '${member.name} (You)' : member.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(member.email, style: TextStyle(color: AppColors.textMuted)),
        trailing: isLeader && !isMe
            ? IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                onPressed: () => _confirmRemoveMember(context, team.id, member.id, member.name),
              )
            : null,
      ),
    );
  }
  
  Widget _buildLinkInviteSection(BuildContext context, ParticipationEntity team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Invite Members'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
             Expanded(
               child: AppTextField(
                 controller: _emailController,
                 hint: 'Enter email address',
                 prefixIcon: Icons.email,
               ),
             ),
             const SizedBox(width: AppSpacing.sm),
             IconButton(
               onPressed: () {
                 if (_emailController.text.isNotEmpty) {
                    context.read<EventsCubit>().inviteToTeam(
                      eventId: widget.eventId,
                      teamId: team.id,
                      email: _emailController.text.trim(),
                    );
                    _emailController.clear();
                 }
               },
               icon: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: const BoxDecoration(
                   color: AppColors.primary,
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.send, color: Colors.white, size: 20),
               ),
             )
          ],
        ),
      ],
    );
  }

  Widget _buildJoinRequestsSection(BuildContext context, String eventId, String teamId) {
    // We need to load requests if logically visible.
    // Done via InitState/LoadData if we want to be clean, or check empty state here.
    // But better to check in build.
    final requests = context.watch<EventsCubit>().state.teamJoinRequests;
    
    if (requests.isEmpty) {
        // Trigger load if empty? Might be loop. better call in loadData
        return const SizedBox.shrink(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Join Requests'),
        const SizedBox(height: AppSpacing.md),
        ...requests.map((req) {
            // Dynamic parsing since it's generic list
            final user = req['user'] ?? {};
            final name = user['name'] ?? 'Unknown';
            final email = user['email'] ?? '';
            final reqId = req['_id'] ?? '';
            
            return Card(
                color: AppColors.bgSecondary.withValues(alpha: 0.5),
                child: ListTile(
                    title: Text(name, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(email, style: TextStyle(color: AppColors.textMuted)),
                    trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            IconButton(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                onPressed: () => context.read<EventsCubit>().respondToJoinRequest(
                                    eventId: eventId, teamId: teamId, requestId: reqId, action: 'ACCEPTED'),
                            ),
                            IconButton(
                                icon: const Icon(Icons.close, color: AppColors.error),
                                onPressed: () => context.read<EventsCubit>().respondToJoinRequest(
                                    eventId: eventId, teamId: teamId, requestId: reqId, action: 'REJECTED'),
                            ),
                        ],
                    ),
                ),
            );
        }),
      ],
    );

  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
    );
  }

  void _showEditTeamDialog(BuildContext context, ParticipationEntity team) {
    _teamNameController.text = team.teamName ?? '';
    // Initialize isPublic from the team entity
    bool isPublic = team.isPublic;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgSecondary,
              title: const Text('Edit Team', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: _teamNameController,
                    label: 'Team Name',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Public/Private Team Toggle
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isPublic
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPublic ? Icons.public : Icons.lock,
                              color: isPublic ? AppColors.primary : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                isPublic ? 'Public Team' : 'Private Team',
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isPublic ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Switch(
                              value: isPublic,
                              onChanged: (value) {
                                setState(() => isPublic = value);
                              },
                              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          isPublic
                              ? 'Other users can find and join your team'
                              : 'Only invited members can join your team',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    context.read<EventsCubit>().editTeam(
                          eventId: widget.eventId,
                          teamId: team.id,
                          teamName: _teamNameController.text,
                          isPublic: isPublic,
                        );
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTeam(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Delete Team?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone. All members will be removed.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            onPressed: () {
              Navigator.pop(context);
              context.read<EventsCubit>().deleteTeam(eventId: widget.eventId, teamId: teamId);
              Navigator.pop(context); // Go back to event page
            },
          ),
        ],
      ),
    );
  }
  
    void _confirmLeaveTeam(BuildContext context, String teamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Leave Team?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to leave this team?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Leave', style: TextStyle(color: AppColors.error)),
            onPressed: () {
               Navigator.pop(context); // Close dialog
               context.read<EventsCubit>().leaveTeam(
                 eventId: widget.eventId,
                 teamId: teamId,
               );
               Navigator.pop(context); // Go back to event page
            },
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, String teamId, String memberId, String memberName) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Remove $memberName?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
            onPressed: () {
              context.read<EventsCubit>().removeTeamMember(eventId: widget.eventId, teamId: teamId, memberId: memberId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
