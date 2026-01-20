import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../../../../components/cards/team_card.dart';
import '../../../../components/buttons/app_button.dart';

/// Public Teams Bottom Sheet to show all public tms for an evnt
/// Allows users to browsee and join existing teams
class PublicTeamsBottomSheet extends StatefulWidget {
  final EventEntity event;

  const PublicTeamsBottomSheet({super.key, required this.event});

  @override
  State<PublicTeamsBottomSheet> createState() => _PublicTeamsBottomSheetState();
}

class _PublicTeamsBottomSheetState extends State<PublicTeamsBottomSheet> {
  String? _joiningTeamId;

  @override
  void initState() {
    super.initState();
    // Load public teams when sheet opens
    context.read<EventsCubit>().loadPublicTeams(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventsCubit, EventsState>(
      listener: (context, state) {
        if (state is TeamJoinSuccess) {
          // Close bottom sheet on success
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is TeamJoinError) {
          setState(() => _joiningTeamId = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(Icons.groups, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Browse Teams',
                            style: AppTextStyles.headlineSmall,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Content
                  Expanded(child: _buildContent(state, scrollController)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(EventsState state, ScrollController scrollController) {
    // Loading State
    if (state is PublicTeamsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State
    if (state is PublicTeamsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Retry',
                icon: Icons.refresh,
                isFullWidth: false,
                onPressed: () {
                  context.read<EventsCubit>().loadPublicTeams(widget.event.id);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Loaded State
    if (state is PublicTeamsLoaded) {
      if (state.teams.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 64,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No teams available yet',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Be the first to create one!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Create Team',
                  icon: Icons.group_add,
                  isFullWidth: false,
                  onPressed: () {
                    Navigator.of(context).pop(); // Close bottom sheet
                    // Parent page will handle team creation
                  },
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<EventsCubit>().loadPublicTeams(widget.event.id);
        },
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: state.teams.length,
          itemBuilder: (context, index) {
            final team = state.teams[index];
            final isJoining = _joiningTeamId == team.id;

            return TeamCard(
              key: ValueKey(team.id),
              team: team,
              maxTeamSize: widget.event.maxTeamSize,
              isLoading: isJoining,
              onJoin: () {
                setState(() => _joiningTeamId = team.id);
                context.read<EventsCubit>().joinTeam(
                  eventId: widget.event.id,
                  teamId: team.id,
                );
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
