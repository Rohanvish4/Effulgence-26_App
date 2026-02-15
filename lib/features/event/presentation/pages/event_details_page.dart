import 'package:effulgence26_mobile_app/core/theme/app_assets.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html_unescape/html_unescape_small.dart';
import '../../../../components/components.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../widgets/public_teams_bottom_sheet.dart';
import '../widgets/team_creation_dialog.dart';
import 'team_management_page.dart';
import 'my_invitations_page.dart';

/// Event Details Page - Redesigned with Particle Background & Glassmorphism
class EventDetailsPage extends StatefulWidget {
  final String eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  List<String> _registeredEventIds = [];
  EventEntity? _event;
  bool _isDialogVisible = false;

   final unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final cubit = context.read<EventsCubit>();
    cubit.getEventDetails(widget.eventId);
    cubit.loadMyParticipations();
    cubit.getMyTeam(widget.eventId);
    cubit.getMyJoinRequests(); // Fetch pending join requests
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        child: BlocConsumer<EventsCubit, EventsState>(
          listener: (context, state) {
            // Event Details Loaded
            if (state.selectedEvent != null) {
              setState(() => _event = state.selectedEvent);
            }

            // Success Messages
            if (state.successMessage != null) {
              _showSnackBar(state.successMessage!, AppColors.success);

              // Handle Team Creation Success - Close Dialog
              if (state.successMessage!.toLowerCase().contains(
                    'team created',
                  ) &&
                  _isDialogVisible) {
                Navigator.of(context).pop();
                _isDialogVisible = false;
              }

              _loadData(); // Refresh data
            }

            // Error Messages
            if (state.errorMessage != null &&
                !state.isEventsLoading &&
                !state.isDetailsLoading &&
                !state.isOperationLoading) {
              if (_event != null) {
                if(state.errorMessage!.contains("not")) {
                  // _showSnackBar("hello", AppColors.primary);
                } else {
                  _showSnackBar(state.errorMessage!, AppColors.error);
                }
                
              }
            }

            // My Participations Loaded
            if (state.myParticipations.isNotEmpty ||
                (!state.isParticipationsLoading &&
                    state.myParticipations.isEmpty)) {
              setState(() {
                _registeredEventIds = state.myParticipations
                    .map((p) => p.eventId)
                    .toList();
              });
            }
          },
          builder: (context, state) {
            if (state.isDetailsLoading && _event == null) {
              return const FullScreenLoading(
                message: 'Loading event details...',
              );
            }

            if (state.errorMessage != null && _event == null) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: ErrorState(
                  message: state.errorMessage!,
                  onRetry: _loadData,
                ),
              );
            }

            final event = _event;
            if (event != null) {
              return RefreshIndicator(
                onRefresh: () async => _loadData(),
                color: AppColors.primary,
                backgroundColor: AppColors.bgSecondary,
                child: CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(event),
                    SliverToBoxAdapter(
                      child: _buildContent(context, event, state),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(EventEntity event) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'event_card_${event.id}',
              child: event.coverImage != null
                  ? CachedNetworkImage(
                      imageUrl: event.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.bgSecondary),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.bgSecondary,
                        child: Image.asset(
                          AppAssets.logoPng,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.bgSecondary,
                      child: const Icon(
                        Icons.event,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgPrimary.withValues(alpha: 0.2),
                    AppColors.bgPrimary,
                  ],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EventEntity event,
    EventsState state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.2),
                            AppColors.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.isTeam ? Icons.groups : Icons.person,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.eventType,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      event.title,
                      style: AppTextStyles.headlineLarge.copyWith(height: 1.1),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: event.status),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            event.domainName,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Info Grid
          _buildInfoGrid(event),

          const SizedBox(height: AppSpacing.xl),

          // Description
          if (event.description != null && event.description!.isNotEmpty) ...[
            _buildSectionTitle('About Event'),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.bgSecondary.withValues(alpha: 0.6),
                    AppColors.bgSecondary.withValues(alpha: 0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                unescape.convert(event.description!),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Rules
          if (event.rules != null && event.rules!.isNotEmpty) ...[
            _buildSectionTitle('Rules & Guidelines'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                event.rules!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Registration Section
          _buildRegistrationSection(context, event, state),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(EventEntity event) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGlassInfoCard(
                icon: Icons.calendar_today,
                title: 'Date',
                value: event.eventTime.formattedDateTime,
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildGlassInfoCard(
                icon: Icons.location_on,
                title: 'Venue',
                value: event.venue,
                color: AppColors.crimsonRed,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGlassInfoCard(
          icon: Icons.timer_outlined,
          title: 'Deadline',
          value: event.registrationDeadline.formattedDateTime,
          color: AppColors.secondary,
          isFullWidth: true,
        ),
        if (event.isTeam) ...[
          const SizedBox(height: AppSpacing.md),
          _buildGlassInfoCard(
            icon: Icons.groups,
            title: 'Team Size',
            value: '${event.minTeamSize} - ${event.maxTeamSize} Members',
            color: AppColors.royalPurple,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildGlassInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isFullWidth = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bgSecondary.withValues(alpha: 0.7),
            AppColors.bgSecondary.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection(
    BuildContext context,
    EventEntity event,
    EventsState state,
  ) {
    if (!event.canRegister) {
      return AppButton(
        text: event.isCompleted ? 'EVENT ENDED' : 'REGISTRATION CLOSED',
        onPressed: null,
        isFullWidth: true,
        backgroundColor: AppColors.bgSecondary,
        textColor: AppColors.textDisabled,
      );
    }

    if (_registeredEventIds.contains(event.id)) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'You are registered!',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (event.isTeam) ...[
            const SizedBox(height: AppSpacing.md),
             AppButton(
              text: 'MANAGE TEAM',
              icon: Icons.settings,
              backgroundColor: AppColors.secondary,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TeamManagementPage(eventId: event.id),
                  ),
                ).then((_) => _loadData());
              },
            ),
          ],
        ],
      );
    }

    if (event.isTeam) {
      // Check if user has a pending join request for this event
      final hasPendingRequest = state.myJoinRequests.any((teamData) {
        final evt = teamData['event'];
        final eventId = evt is Map ? (evt['_id']?.toString() ?? '') : '';
        final requests = teamData['joinRequests'] as List<dynamic>? ?? [];
        return eventId == event.id && requests.any((r) => r['status'] == 'PENDING');
      });

      if (hasPendingRequest) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Request Pending',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Waiting for team leader to accept your request.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ),

               AppTextButton(
            text: 'Check My Invitations',
            icon: Icons.mail,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyInvitationsPage(),
                ),
              );
            },
          )
            ],
          ),
        );
      }

      return Column(
        children: [
          GradientButton(
            text: 'CREATE TEAM & REGISTER',
            icon: Icons.group_add,
            isLoading: state.isOperationLoading,
            onPressed: () {
              _showTeamCreationDialog(context, event.id);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextButton(
            text: 'Or Browse Existing Teams',
            icon: Icons.groups,
            onPressed: () => _showPublicTeamsSheet(context, event),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextButton(
            text: 'Check My Invitations',
            icon: Icons.mail,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyInvitationsPage(),
                ),
              );
            },
          )
        ],
      );
    }

    return GradientButton(
      text: 'REGISTER NOW',
      icon: Icons.how_to_reg,
      isLoading: state.isOperationLoading,
      onPressed: () {
        context.read<EventsCubit>().registerForEvent(event.id);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _showTeamCreationDialog(BuildContext context, String eventId) {
    final eventsCubit = context.read<EventsCubit>();
    final teamNameController = TextEditingController();
    _isDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: eventsCubit,
        child: TeamCreationDialogContent(
          eventId: eventId,
          teamNameController: teamNameController,
          eventsCubit: eventsCubit,
          onClose: () {
            Navigator.pop(dialogContext);
            _isDialogVisible = false;
          },
        ),
      ),
    ).then((_) {
      // Ensure flag is reset if dialog is dismissed by back button
      _isDialogVisible = false;
    });
  }

  void _showPublicTeamsSheet(BuildContext context, EventEntity event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: context.read<EventsCubit>(),
        child: PublicTeamsBottomSheet(event: event),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
