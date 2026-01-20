import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../components/components.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';
import '../widgets/public_teams_bottom_sheet.dart';
import '../widgets/team_creation_dialog.dart';

/// Event Details Page - Premium UI with Hero Animation & Glassmorphism
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventsCubit>().getEventDetails(widget.eventId);
    context.read<EventsCubit>().loadMyParticipations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocConsumer<EventsCubit, EventsState>(
        listener: (context, state) {
          if (state is EventDetailsLoaded) {
            setState(() => _event = state.event);
          } else if (state is EventRegistrationSuccess) {
            _showSnackBar(state.message, AppColors.success);
            _loadData(); // Refresh data
          } else if (state is EventRegistrationError) {
            _showSnackBar(state.message, AppColors.error);
          } else if (state is TeamCreationSuccess) {
            if (_isDialogVisible) {
              Navigator.of(context).pop(); // Close dialog on success
              _isDialogVisible = false;
            }
            _showSnackBar(state.message, AppColors.success);
            _loadData(); // Refresh data
          } else if (state is TeamCreationError) {
            // Keep dialog open on error so user can retry/fix
            _showSnackBar(state.message, AppColors.error);
          } else if (state is MyParticipationsLoaded) {
            setState(() {
              _registeredEventIds = state.participations
                  .map((p) => p.eventId)
                  .toList();
            });
          }
        },
        builder: (context, state) {
          if (state is EventDetailsLoading && _event == null) {
            return const FullScreenLoading(message: 'Loading event details...');
          }

          if (state is EventDetailsError && _event == null) {
            return Scaffold(
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: ErrorState(message: state.message, onRetry: _loadData),
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
    );
  }

  Widget _buildSliverAppBar(EventEntity event) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.bgPrimary,
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
                        child: const Icon(
                          Icons.image_not_supported,
                          color: AppColors.textMuted,
                          size: 50,
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
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        event.eventType,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              event.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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
          color: AppColors.amberGold,
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
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
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
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: AppSpacing.md),
            Text(
              'You are registered!',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    if (event.isTeam) {
      return Column(
        children: [
          GradientButton(
            text: 'CREATE TEAM & REGISTER',
            icon: Icons.group_add,
            isLoading: state is TeamCreationLoading,
            onPressed: () {
              _showTeamCreationDialog(context, event.id);
              setState(() {});
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextButton(
            text: 'Or Browse Existing Teams',
            icon: Icons.groups,
            onPressed: () => _showPublicTeamsSheet(context, event),
          ),
        ],
      );
    }

    return GradientButton(
      text: 'REGISTER NOW',
      icon: Icons.how_to_reg,
      isLoading: state is EventRegistrationLoading,
      onPressed: () {
        context.read<EventsCubit>().registerForEvent(event.id);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.titleLarge),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
