import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

/// Events List Page - Premium UI with Slivers & Glassmorphism
/// Fixed: Local state caching ensures events persist when navigating back from details.
class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  String? _selectedStatus; // Filter: 'UPCOMING', 'LIVE', 'COMPLETED'
  String? _registeringEventId; // Track which event is being registered for
  List<String> _registeredEventIds = []; // Track registered event IDs
  final ScrollController _scrollController = ScrollController();

  // LOCAL STATE CACHING: Stores events to survive state changes from other pages
  List<EventEntity>? _cachedEvents;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadUserParticipations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    context.read<EventsCubit>().loadEvents(refresh: true);
  }

  void _loadUserParticipations() {
    context.read<EventsCubit>().loadMyParticipations();
  }

  void _handleRegistration(String eventId, String eventType) {
    if (eventType == 'TEAM') {
      context.push('/events/$eventId');
      return;
    }

    setState(() => _registeringEventId = eventId);
    context.read<EventsCubit>().registerForEvent(eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocListener<EventsCubit, EventsState>(
        listener: (context, state) {
          // Handle events list loading states
          if (state is EventsLoaded) {
            setState(() {
              _cachedEvents = state.events;
              _isLoading = false;
              _errorMessage = null;
            });
          }

          if (state is EventsLoading) {
            // Only show loading if we don't have cached data
            if (_cachedEvents == null) {
              setState(() => _isLoading = true);
            }
          }

          if (state is EventsError) {
            setState(() {
              _isLoading = false;
              _errorMessage = state.message;
            });
          }

          // Handle registration states
          if (state is EventRegistrationSuccess) {
            _showSnackBar(state.message, AppColors.success);
            setState(() => _registeringEventId = null);
            _loadEvents();
            _loadUserParticipations();
          }

          if (state is EventRegistrationError) {
            _showSnackBar(state.message, AppColors.error);
            setState(() => _registeringEventId = null);
          }

          // Handle participations states
          if (state is MyParticipationsLoaded) {
            setState(() {
              _registeredEventIds = state.participations
                  .map((participation) => participation.eventId)
                  .toList();
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _loadEvents();
            _loadUserParticipations();
          },
          color: AppColors.primary,
          backgroundColor: AppColors.bgSecondary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: _buildFilterSection()),
              _buildEventsList(),
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
      backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.8),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Tooltip(
            message: 'My Events',
            child: AppIconButton(
              icon: Icons.calendar_month_rounded,
              onPressed: () => context.push('/my-events'),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: 16),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'EVENTS',
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
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 60,
                      spreadRadius: 20,
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

  Widget _buildFilterSection() {
    final statuses = ['All', 'UPCOMING', 'LIVE', 'COMPLETED'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: statuses.length,
          separatorBuilder: (context, index) =>
              const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final status = statuses[index];
            final isSelected =
                (status == 'All' && _selectedStatus == null) ||
                status == _selectedStatus;

            return _buildFilterChip(status, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final newStatus = label == 'All' ? null : label;
        if (newStatus != _selectedStatus) {
          setState(() {
            _selectedStatus = newStatus;
            // Filter is applied locally in _buildEventsList using cached data
          });
          // No API call needed if we have updated cache logic
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    // Show loading state
    if (_isLoading && _cachedEvents == null) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: ShimmerEventCard(),
          ),
          childCount: 5,
        ),
      );
    }

    // Show error state
    if (_errorMessage != null && _cachedEvents == null) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorState(message: _errorMessage!, onRetry: _loadEvents),
      );
    }

    // CLIENT-SIDE FILTERING
    var events = _cachedEvents ?? [];

    // Apply status filter if one is selected
    if (_selectedStatus != null) {
      events = events
          .where((event) => event.status == _selectedStatus)
          .toList();
    }

    // Show empty state
    if (events.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.event_busy,
          title: 'No Events Found',
          message: _selectedStatus != null
              ? 'No events found with status "$_selectedStatus"'
              : 'Check back later for upcoming events.',
          actionLabel: 'Refresh',
          onAction: () {
            // Reset filter and load everyone
            setState(() {
              _selectedStatus = null;
              _loadEvents();
            });
          },
        ),
      );
    }

    // Show events list
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final event = events[index];
        final isRegistering = _registeringEventId == event.id;
        final isRegistered = _registeredEventIds.contains(event.id);

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Hero(
            tag: 'event_card_${event.id}',
            child: EventCard(
              title: event.title,
              domain: event.domainName,
              imageUrl: event.coverImage ?? '',
              venue: event.venue,
              dateTime: event.eventTime,
              status: event.status,
              showRegisterButton: true,
              isRegistered: isRegistered,
              isRegistering: isRegistering,
              eventType: event.eventType,
              onTap: () => context.push('/events/${event.id}'),
              onRegister: event.canRegister && !isRegistered
                  ? () => _handleRegistration(event.id, event.eventType)
                  : null,
            ),
          ),
        );
      }, childCount: events.length),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
