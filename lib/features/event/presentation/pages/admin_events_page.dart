import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/components.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../pages/admin_event_registrations_page.dart';
import '../../domain/entities/event_entity.dart';

/// Admin Events Management Page - Emerald Titanium Design System
/// Optimized with Particle Background and Glassmorphic layers
class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  bool _showDeletedEvents = false;
  final TextEditingController _searchController =
      TextEditingController(); // Search controller
  String _searchQuery = ''; // Search query state

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _loadEvents();
  }

  void _checkAdminAccess() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (!authState.user.isAdmin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied: Admin privileges required'),
              backgroundColor: AppColors.error,
            ),
          );
        });
      }
    }
  }

  void _loadEvents() {
    context.read<EventsCubit>().loadEvents(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.dense,
        child: BlocListener<EventsCubit, EventsState>(
          listener: (context, state) {
            if (state.successMessage != null && !state.isOperationLoading) {
              _showSnackBar(state.successMessage!, AppColors.success);
            }
          },
          child: RefreshIndicator(
            onRefresh: () async => _loadEvents(),
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
                    hintText: 'Search operations...',
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
                // _buildStatsSection(),
                _buildEventsListSection(),
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => context.push('/qr-scanner'),
      //   label: const Text('SCAN ENTRY'),
      //   icon: const Icon(Icons.qr_code_scanner_rounded),
      //   backgroundColor: AppColors.primary,
      //   foregroundColor: Colors.black,
      // ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.info),
          // Update inside _buildSliverAppBar's info IconButton
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor:
                  Colors.transparent, // Required for custom shape/glass
              barrierColor: Colors.black.withValues(alpha: 0.7),
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          'SYSTEM ANALYTICS',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<EventsCubit, EventsState>(
                          builder: (context, state) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'TOTAL',
                                  state.events.length.toString(),
                                  Icons.analytics_outlined,
                                ),
                                // _buildStatItem(
                                //   'ACTIVE',
                                //   state.events
                                //       .where((e) => !e.isDeleted)
                                //       .length
                                //       .toString(),
                                //   Icons.check_circle_outline,
                                // ),
                                _buildStatItem(
                                  'LIVE',
                                  state.events
                                      .where((e) => e.isLive && !e.isDeleted)
                                      .length
                                      .toString(),
                                  Icons.sensors_rounded,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => context.push('/qr-scanner'),
        ),
        // IconButton(
        //   icon: const Icon(Icons.refresh_rounded),
        //   onPressed: _loadEvents,
        // ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'CONTROL CENTER',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Operations',
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

  // Widget _buildStatsSection() {
  //   return SliverToBoxAdapter(
  //     child: BlocBuilder<EventsCubit, EventsState>(
  //       builder: (context, state) {
  //         if (state.events.isEmpty) return const SizedBox.shrink();

  //         return Container(
  //           margin: const EdgeInsets.all(AppSpacing.md),
  //           padding: const EdgeInsets.all(AppSpacing.lg),
  //           decoration: BoxDecoration(
  //             color: AppColors.surface.withValues(alpha: 0.4),
  //             borderRadius: BorderRadius.circular(20),
  //             border: Border.all(
  //               color: AppColors.primary.withValues(alpha: 0.3),
  //             ),
  //           ),
  //           child: ClipRRect(
  //             child: BackdropFilter(
  //               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   _buildStatItem(
  //                     'TOTAL',
  //                     state.events.length.toString(),
  //                     Icons.analytics_outlined,
  //                   ),
  //                   _buildStatItem(
  //                     'ACTIVE',
  //                     state.events.where((e) => !e.isDeleted).length.toString(),
  //                     Icons.check_circle_outline,
  //                   ),
  //                   _buildStatItem(
  //                     'LIVE',
  //                     state.events
  //                         .where((e) => e.isLive && !e.isDeleted)
  //                         .length
  //                         .toString(),
  //                     Icons.sensors_rounded,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildEventsListSection() {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state.isEventsLoading && state.events.isEmpty) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const Padding(
                padding: EdgeInsets.all(16),
                child: ShimmerCard(height: 120),
              ),
              childCount: 4,
            ),
          );
        }

        final displayEvents = _showDeletedEvents
            ? state.events.where((e) => e.isDeleted).toList()
            : state.events.where((e) => !e.isDeleted).toList();

        // Apply Search Filter
        final filteredEvents = displayEvents.where((e) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return e.title.toLowerCase().contains(query) ||
              e.domainName.toLowerCase().contains(query) ||
              e.eventType.toLowerCase().contains(query);
        }).toList();

        if (filteredEvents.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.radar_rounded,
              title: 'NO DATA DETECTED',
              message: 'System awaiting event initialization.',
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildAdminEventCard(filteredEvents[index]),
            childCount: filteredEvents.length,
          ),
        );
      },
    );
  }

  Widget _buildAdminEventCard(dynamic event) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                title: Text(
                  event.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                subtitle: Text(
                  '${event.domain} • ${event.eventType}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: _buildStatusBadge(event),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(event.venue, style: AppTextStyles.bodySmall),
                    const Spacer(),
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(event.eventTime),
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 32,
                indent: 20,
                endIndent: 20,
                color: AppColors.border,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: _buildActiveEventActions(event),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveEventActions(dynamic event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: AppTextButton(
            onPressed: () => context.push('/events/${event.id}'),
            icon: Icons.visibility_outlined,
            text: 'DETAILS',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppTextButton(
            onPressed: () => _showViewRegistrationsDialog(event),
            icon: Icons.people_outline_rounded,
            text: 'INSIGHTS',
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(dynamic event) {
    Color badgeColor = event.isLive
        ? AppColors.eventLive
        : (event.isUpcoming ? AppColors.eventUpcoming : AppColors.textMuted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        event.status.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showViewRegistrationsDialog(dynamic event) {
    if (event is! EventEntity) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AdminEventRegistrationsPage(event: event),
      ),
    );
  }

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
