import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/participation_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

/// My Events Page - Shows user's registered events and participation status
/// Uses local state caching to survive cubit state changes from other pages.
class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  // Local state caching
  List<ParticipationEntity>? _cachedParticipations;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadParticipations();
  }

  void _loadParticipations() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    context.read<EventsCubit>().loadMyParticipations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocListener<EventsCubit, EventsState>(
        listener: (context, state) {
          if (state is MyParticipationsLoaded) {
            setState(() {
              _cachedParticipations = state.participations;
              _isLoading = false;
              _errorMessage = null;
            });
          }

          if (state is MyParticipationsLoading) {
            if (_cachedParticipations == null) {
              setState(() => _isLoading = true);
            }
          }

          if (state is MyParticipationsError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: () async => _loadParticipations(),
          color: AppColors.primary,
          backgroundColor: AppColors.bgSecondary,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildParticipationsList(),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.9),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.secondaryGradient.createShader(bounds),
          child: Text(
            'MY EVENTS',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        background: Stack(
          children: [
            Container(color: AppColors.bgPrimary),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.15),
                      blurRadius: 50,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationsList() {
    // Show loading state
    if (_isLoading && _cachedParticipations == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: FullScreenLoading(message: 'Loading your events...'),
      );
    }

    // Show error state
    if (_errorMessage != null && _cachedParticipations == null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(
          message: _errorMessage!,
          onRetry: _loadParticipations,
        ),
      );
    }

    final participations = _cachedParticipations ?? [];

    // Show empty state
    if (participations.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.event_busy,
          title: 'No Events Yet',
          message:
              'You haven\'t registered for any events.\nExplore events and register now!',
          actionLabel: 'Browse Events',
          onAction: () => context.go('/'),
        ),
      );
    }

    // Show participations list
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final participation = participations[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: _buildParticipationCard(context, participation),
        );
      }, childCount: participations.length),
    );
  }

  Widget _buildParticipationCard(
    BuildContext context,
    ParticipationEntity participation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events/${participation.eventId}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event info header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        participation.isTeam ? Icons.groups : Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event ID: ${participation.eventId.substring(0, 8)}...',
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (participation.isTeam &&
                              participation.teamName != null)
                            Text(
                              'Team: ${participation.teamName}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Participation details
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildInfoChip(
                      participation.isIndividual ? 'Individual' : 'Team',
                      participation.isIndividual ? Icons.person : Icons.groups,
                      AppColors.primary,
                    ),
                    if (participation.isPresent)
                      _buildInfoChip(
                        'Present',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    if (participation.isQualified)
                      _buildInfoChip(
                        'Qualified',
                        Icons.verified,
                        AppColors.warning,
                      ),
                    if (participation.rank != null)
                      _buildInfoChip(
                        'Rank: ${participation.rank}',
                        Icons.emoji_events,
                        AppColors.warning,
                      ),
                  ],
                ),

                if (participation.score > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.score,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Score: ${participation.score}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Registration date
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgOverlay,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Registered: ${_formatDate(participation.registeredAt)}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
