import 'dart:ui';
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

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<ParticipationEntity>? _cachedParticipations;
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController =
      TextEditingController(); // Search controller
  String _searchQuery = ''; // Search query state

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.dense,
        child: BlocListener<EventsCubit, EventsState>(
          listener: _handleStateChanges,
          child: RefreshIndicator(
            onRefresh: () async => _loadParticipations(),
            color: AppColors.primary,
            backgroundColor: AppColors.bgSecondary,
            edgeOffset: 120,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: AppGlassSearchBar(
                    controller: _searchController,
                    hintText: 'Search my registrations...',
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                _buildParticipationsList(),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, EventsState state) {
    if (state.successMessage != null) {
      _showSnackBar(state.successMessage!, AppColors.success);
    }

    if (state.errorMessage != null) {
      if (!state.isParticipationsLoading && state.myParticipations.isNotEmpty) {
        _showSnackBar(state.errorMessage!, AppColors.error);
      } else if (state.myParticipations.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = state.errorMessage;
        });
      }
    }

    if (!state.isParticipationsLoading && state.errorMessage == null) {
      setState(() {
        _cachedParticipations = state.myParticipations;
        _isLoading = false;
        _errorMessage = null;
      });
    }

    if (state.isParticipationsLoading && _cachedParticipations == null) {
      setState(() => _isLoading = true);
    }
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppIconButton(
          icon: Icons.chevron_left_rounded,
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURED OPS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'My Registrations',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.bgPrimary,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipationsList() {
    if (_isLoading && _cachedParticipations == null) {
      return const SliverFillRemaining(
        child: FullScreenLoading(message: 'Syncing tactical data...'),
      );
    }

    if (_errorMessage != null && _cachedParticipations == null) {
      return SliverFillRemaining(
        child: ErrorState(
          message: _errorMessage!,
          onRetry: _loadParticipations,
        ),
      );
    }

    var participations = _cachedParticipations ?? [];

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      participations = participations.where((p) {
        final matchesTeam = p.teamName?.toLowerCase().contains(query) ?? false;
        final matchesEventID = p.eventId.toLowerCase().contains(query);
        return matchesTeam || matchesEventID; // Basic search logic
      }).toList();
    }

    if (participations.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.radar_rounded,
          title: 'NO ACTIVE OPS',
          message:
              'Initialize your first engagement by browsing the event timeline.',
          actionLabel: 'EXPLORE TIMELINE',
          onAction: () => context.go('/'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: _buildParticipationCard(context, participations[index]),
        );
      }, childCount: participations.length),
    );
  }

  Widget _buildParticipationCard(BuildContext context, ParticipationEntity p) {
    final eventList = context
        .read<EventsCubit>()
        .state
        .events
        .where((e) => e.id == p.eventId)
        .toList();
    final eventName =
        eventList.isNotEmpty ? eventList.first.title : 'Unknown Event';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: InkWell(
            onTap: () => context.push('/events/${p.eventId}'),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildIndicatorIcon(p.isTeam),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName.toUpperCase(),
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.isTeam
                                  ? 'TEAM: ${p.teamName?.toUpperCase() ?? "N/A"}'
                                  : 'SOLO PARTICIPATION',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'REF: ${p.eventId.isNotEmpty ? (p.eventId.length > 12 ? p.eventId.substring(0, 12).toUpperCase() : p.eventId.toUpperCase()) : "N/A"}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusRow(p),
                  const Divider(height: 32, color: AppColors.border),
                  _buildCardFooter(context, p),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorIcon(bool isTeam) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Icon(
        isTeam ? Icons.groups_rounded : Icons.person_rounded,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildStatusRow(ParticipationEntity p) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (p.isPresent)
          _buildMetricChip('PRESENT', Icons.sensors_rounded, AppColors.success),
        if (p.isQualified)
          _buildMetricChip(
            'QUALIFIED',
            Icons.verified_user_rounded,
            AppColors.secondary,
          ),
        if (p.rank != null)
          _buildMetricChip(
            'RANK #${p.rank}',
            Icons.emoji_events_rounded,
            AppColors.warning,
          ),
        if (p.score > 0)
          _buildMetricChip(
            'SCORE: ${p.score}',
            Icons.analytics_rounded,
            AppColors.primary,
          ),
      ],
    );
  }

  Widget _buildMetricChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, ParticipationEntity p) {
    return Row(
      children: [
        Icon(Icons.history_rounded, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          'SYNCED: ${_formatDate(p.registeredAt)}',
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
        ),
        const Spacer(),
        if (p.isTeam)
          GestureDetector(
            onTap: () => _confirmLeaveTeam(
              context,
              p.eventId,
              p.id,
              p.teamName ?? 'Unit',
            ),
            child: Text(
              'ABORT TEAM',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  void _confirmLeaveTeam(
    BuildContext context,
    String eventId,
    String teamId,
    String teamName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('ABORT TEAM?', style: AppTextStyles.titleMedium),
        content: Text(
          'Confirming the removal of unit "$teamName" from the registry.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.read<EventsCubit>().leaveTeam(
                eventId: eventId,
                teamId: teamId,
              );
            },
            child: const Text(
              'CONFIRM ABORT',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
