import 'dart:async';

import 'package:effulgence26_mobile_app/core/services/remote_config_service.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_cubit.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_state.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:effulgence26_mobile_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:effulgence26_mobile_app/components/components.dart';

class EventTimelinePage extends StatefulWidget {
  const EventTimelinePage({super.key});

  @override
  State<EventTimelinePage> createState() => _EventTimelinePageState();
}

class _EventTimelinePageState extends State<EventTimelinePage>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _eventItemKeys = {};

  Timer? _timelineTicker;
  String? _lastAutoFocusedEventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Load events if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsCubit>().loadEvents();
      context.read<EventsCubit>().refreshTimelineItems();
    });

    _startTimelineTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimelineTicker();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startTimelineTicker();
        context.read<EventsCubit>().refreshTimelineItems();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopTimelineTicker();
        break;
    }
  }

  void _startTimelineTicker() {
    _timelineTicker ??= Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      context.read<EventsCubit>().refreshTimelineItems();
    });
  }

  void _stopTimelineTicker() {
    _timelineTicker?.cancel();
    _timelineTicker = null;
  }

  void _autoFocusNextEvent(EventsState state) {
    final nextIndex = state.timelineItems.indexWhere(
      (item) =>
          item.phase == TimelinePhase.live ||
          item.phase == TimelinePhase.upcomingSoon ||
          item.phase == TimelinePhase.upcoming,
    );

    if (nextIndex == -1) return;

    final nextEventId = state.timelineItems[nextIndex].event.id;
    if (_lastAutoFocusedEventId == nextEventId) return;

    _lastAutoFocusedEventId = nextEventId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final targetContext = _eventItemKeys[nextEventId]?.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.getElementsForDay(
          context.read<RemoteConfigService>().techfestDay,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocConsumer<EventsCubit, EventsState>(
                  listenWhen:
                      (previous, current) =>
                          previous.timelineItems != current.timelineItems,
                  listener: (context, state) {
                    if (state.timelineItems.isNotEmpty) {
                      _autoFocusNextEvent(state);
                    }
                  },
                  builder: (context, state) {
                    if (state.isEventsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.errorMessage!,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<EventsCubit>().loadEvents(
                                    refresh: true,
                                  );
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (state.timelineItems.isEmpty) {
                      return Center(
                        child: Text(
                          "No events scheduled yet.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    }

                    final liveCount =
                        state.timelineItems
                            .where((item) => item.phase == TimelinePhase.live)
                            .length;
                    final upcomingCount =
                        state.timelineItems
                            .where(
                              (item) =>
                                  item.phase == TimelinePhase.upcoming ||
                                  item.phase == TimelinePhase.upcomingSoon,
                            )
                            .length;
                    final endedCount =
                        state.timelineItems
                            .where((item) => item.phase == TimelinePhase.ended)
                            .length;

                    final nextEventIndex = state.timelineItems.indexWhere(
                      (item) =>
                          item.phase == TimelinePhase.live ||
                          item.phase == TimelinePhase.upcomingSoon ||
                          item.phase == TimelinePhase.upcoming,
                    );
                    final nextEvent =
                        nextEventIndex != -1
                            ? state.timelineItems[nextEventIndex].event
                            : null;
                    final nextEventStatus =
                        nextEventIndex != -1
                            ? state.timelineItems[nextEventIndex]
                            : null;

                    return Column(
                      children: [
                        _buildTimelineInsights(
                          liveCount: liveCount,
                          upcomingCount: upcomingCount,
                          endedCount: endedCount,
                          nextEvent: nextEvent,
                          nextEventStatus: nextEventStatus,
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: state.timelineItems.length,
                            itemBuilder: (context, index) {
                              final item = state.timelineItems[index];
                              final isLast =
                                  index == state.timelineItems.length - 1;
                              final eventId = item.event.id;
                              final key = _eventItemKeys.putIfAbsent(
                                eventId,
                                () => GlobalKey(),
                              );

                              return KeyedSubtree(
                                key: key,
                                child: _buildTimelineItem(item, isLast, index),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          HeroGradientBorder(
            shape: BoxShape.circle,
            borderRadius: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgPrimary,
              ),
              child: const Icon(
                Icons.timeline_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "EVENT CHRONICLE",
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "SCHEDULE & TIMELINE",
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineInsights({
    required int liveCount,
    required int upcomingCount,
    required int endedCount,
    required EventEntity? nextEvent,
    required TimelineItemModel? nextEventStatus,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatChip(
                  icon: Icons.bolt_rounded,
                  label: '$liveCount Live',
                  color: AppColors.eventLive,
                ),
                _buildStatChip(
                  icon: Icons.schedule_rounded,
                  label: '$upcomingCount Upcoming',
                  color: AppColors.warning,
                ),
                _buildStatChip(
                  icon: Icons.task_alt_rounded,
                  label: '$endedCount Ended',
                  color: AppColors.textMuted,
                ),
              ],
            ),
            if (nextEvent != null && nextEventStatus != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Next: ${nextEvent.title} • ${nextEventStatus.relativeLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItemModel item, bool isLast, int index) {
    final event = item.event;
    final statusColor = _statusColor(item.phase);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event.eventTime.formattedDate.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  event.eventTime.formattedTime,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.shortLabel,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: statusColor.withValues(alpha: 0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgPrimary,
                  border: Border.all(color: statusColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor,
                          statusColor.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Event Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.16),
                      blurRadius: 14,
                      spreadRadius: -2,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Subtle holographic grid/pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.03,
                          child: GridPaper(
                            color: AppColors.primary,
                            interval: 20,
                            divisions: 1,
                            subdivisions: 1,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _buildStatusTag(item),
                                _buildTag(event.eventType, AppColors.secondary),
                                _buildTag(event.domain, AppColors.accent),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              event.title,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event.eventVenue,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                item.relativeLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (event.endTime != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.flag_circle_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Ends ${event.endTime!.formattedDateTime}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(TimelineItemModel item) {
    final color = _statusColor(item.phase);
    final icon = _statusIcon(item.phase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            item.chipLabel,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(TimelinePhase phase) {
    switch (phase) {
      case TimelinePhase.live:
        return AppColors.eventLive;
      case TimelinePhase.upcomingSoon:
        return AppColors.warning;
      case TimelinePhase.upcoming:
        return AppColors.eventUpcoming;
      case TimelinePhase.ended:
        return AppColors.eventCompleted;
    }
  }

  IconData _statusIcon(TimelinePhase phase) {
    switch (phase) {
      case TimelinePhase.live:
        return Icons.bolt_rounded;
      case TimelinePhase.upcomingSoon:
        return Icons.notifications_active_rounded;
      case TimelinePhase.upcoming:
        return Icons.schedule_rounded;
      case TimelinePhase.ended:
        return Icons.check_circle_outline_rounded;
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: Text(
          text.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
