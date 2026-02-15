import 'package:cached_network_image/cached_network_image.dart';
import 'package:effulgence26_mobile_app/core/theme/app_assets.dart';
import 'package:effulgence26_mobile_app/core/utils/debounce_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../components/components.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/event_entity.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

/// Events List Page - Optimized with Caching & Fixed Filters
class EventsListPage extends StatefulWidget {
  const EventsListPage({super.key});

  @override
  State<EventsListPage> createState() => _EventsListPageState();
}

class _EventsListPageState extends State<EventsListPage> {
  String? _selectedDomain;
  String? _registeringEventId;
  List<String> _registeredEventIds = [];
  final ScrollController _scrollController = ScrollController();
 

  // Caching
  List<EventEntity>? _cachedEvents;
  List<EventEntity>? _cachedFilteredEvents;
  bool _isLoading = true;
  String? _errorMessage;
  int _filterChangeKey = 0;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Debouncing for search (using Debouncer utility)
  late final Debouncer _searchDebouncer;

  @override
  void initState() {
    super.initState();
    // Initialize debouncer with 500ms delay
    _searchDebouncer = Debouncer(milliseconds: 500);
    _loadEvents();
    _loadUserParticipations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebouncer.dispose();  // Clean up debouncer
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

  /// Apply filters and search to cached events
  List<EventEntity> _getFilteredEvents() {
    if (_cachedEvents == null) return [];

    var events = List<EventEntity>.from(_cachedEvents!);

    // Apply domain filter
    if (_selectedDomain != null && _selectedDomain!.isNotEmpty) {
      events = events.where((e) {
        return e.domainName.toLowerCase() == _selectedDomain!.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      events = events.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.domainName.toLowerCase().contains(query) ||
            (e.description?.toLowerCase().contains(query) ?? false) ||
            e.eventType.toLowerCase().contains(query);
      }).toList();
    }

    // Sort alphabetically by title
    events.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return events;
  }

  /// Handle search with debouncing using Debouncer utility
  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      setState(() {
        _searchQuery = value;
        _cachedFilteredEvents = _getFilteredEvents();
        _filterChangeKey++;
      });
    });
  }

  /// Handle domain filter change
  void _onDomainFilterChanged(String? domain) {
    setState(() {
      _selectedDomain = domain;
      _cachedFilteredEvents = _getFilteredEvents();
      _filterChangeKey++;
    });
  }

  /// Clear all filters
  void _clearAllFilters() {
    setState(() {
      _selectedDomain = null;
      _searchQuery = '';
      _searchController.clear();
      _cachedFilteredEvents = _getFilteredEvents();
      _filterChangeKey++;
      _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.dense,
        child: BlocListener<EventsCubit, EventsState>(
          listener: (context, state) {
            // Handle events loading success
            if (state.status == EventsStatus.success) {
              setState(() {
                _cachedEvents = state.events;
                _cachedFilteredEvents = _getFilteredEvents();
                _isLoading = false;
                _errorMessage = null;
              });
            }

            // Handle events loading
            if (state.isEventsLoading && _cachedEvents == null) {
              setState(() => _isLoading = true);
            }

            // Handle error
            if (state.errorMessage != null &&
                !state.isEventsLoading &&
                state.events.isEmpty) {
              setState(() {
                _isLoading = false;
                _errorMessage = state.errorMessage;
              });
            }

            // Handle registration success
            if (state.successMessage?.toLowerCase().contains("register") ==
                true) {
              _showSnackBar(state.successMessage!, AppColors.success);
              setState(() => _registeringEventId = null);
              _loadEvents();
              _loadUserParticipations();
            }

            // Handle participations loaded
            if (!state.isParticipationsLoading &&
                state.myParticipations.isNotEmpty) {
              setState(() {
                _registeredEventIds = state.myParticipations
                    .map((e) => e.eventId)
                    .toList();
              });
            }

            // Handle registration error
            if (state.errorMessage != null && _registeringEventId != null) {
              _showSnackBar(state.errorMessage!, AppColors.error);
              setState(() => _registeringEventId = null);
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
                SliverToBoxAdapter(
                  child: AppGlassSearchBar(
                    controller: _searchController,
                    hintText: 'Search events...',
                    onChanged: _onSearchChanged,
                    onClear: () {
                      setState(() {
                        _searchQuery = '';
                        _cachedFilteredEvents = _getFilteredEvents();
                        _filterChangeKey++;
                      });
                    },
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFilterSection()),
                _buildEventsList(),
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
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
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'EVENTS',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'COMPETE & WIN',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgPrimary.withValues(alpha: 0.9),
                AppColors.bgPrimary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final domains = [
      'All',
      'programming',
      'robotics',
      'entrepreneurial',
      'miscellaneous',
      'ESPORTS',
    ];
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
          itemCount: domains.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) {
            final domain = domains[index];
            final isSelected =
                (domain == 'All' && _selectedDomain == null) ||
                (_selectedDomain != null &&
                    domain.toLowerCase() == _selectedDomain!.toLowerCase());
            return _buildFilterChip(domain, isSelected);
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        final newDomain = label == 'All' ? null : label;
        _onDomainFilterChanged(newDomain);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.15),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              letterSpacing: 0.5,
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
          (_, __) => const Padding(
            padding: EdgeInsets.all(8.0),
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

    // Get filtered events from cache
    final events = _cachedFilteredEvents ?? _getFilteredEvents();

    // Show empty state
    if (events.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.event_busy,
          title: 'No Events Found',
          message: _searchQuery.isNotEmpty || _selectedDomain != null
              ? 'Try adjusting your filters'
              : 'Stay tuned for more updates!',
          actionLabel: 'Clear Filters',
          onAction: _clearAllFilters,
        ),
      );
    }

    // Show events list
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final event = events[index];
        final isRegistered = _registeredEventIds.contains(event.id);
        final isRegistering = _registeringEventId == event.id;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: SlideInAnimation(
            key: ValueKey('${event.id}_$_filterChangeKey'),
            duration: AppDurations.medium,
            delay: Duration(milliseconds: index * 50),
            beginOffset: const Offset(0, 0.2),
            curve: AppCurves.easeIn,
            child: _buildGlassEventCard(event, isRegistered, isRegistering),
          ),
        );
      }, childCount: events.length),
    );
  }

  Widget _buildGlassEventCard(
    EventEntity event,
    bool isRegistered,
    bool isRegistering,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events/${event.id}'),
          splashColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Column(
            children: [
              // Image Area with Caching
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (event.coverImage?.isNotEmpty ?? false)
                      CachedNetworkImage(
                        imageUrl: event.coverImage!,
                        fit: BoxFit.cover,
                        // Memory cache configuration
                        memCacheHeight: 300,
                        memCacheWidth: 600,
                        // Aggressive caching
                        maxHeightDiskCache: 400,
                        maxWidthDiskCache: 800,
                        placeholder: (context, url) => Container(
                          color: AppColors.bgSecondary.withValues(alpha: 0.5),
                          child: Center(
                            child: Image.asset(
                              AppAssets.logoPng,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.bgSecondary),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.bgSecondary,
                              AppColors.bgPrimary,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.event,
                          color: AppColors.textMuted.withValues(alpha: 0.3),
                          size: 60,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            AppColors.bgSecondary.withValues(alpha: 0.95),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          event.domainName.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content Area
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.eventTime.toString().split(' ')[0],
                          style: AppTextStyles.bodySmall,
                        ),
                        const Spacer(),
                        if (isRegistered)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd,
                              ),
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'REGISTERED',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (event.canRegister)
                          SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: isRegistering
                                  ? null
                                  : () => _handleRegistration(
                                      event.id,
                                      event.eventType,
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primary.withValues(
                                  alpha: 0.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: isRegistering
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                        strokeCap: StrokeCap.round,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.how_to_reg, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          'REGISTER',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
