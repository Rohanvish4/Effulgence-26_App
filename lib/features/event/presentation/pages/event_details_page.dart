import 'package:effulgence26_mobile_app/core/theme/app_assets.dart';
import 'package:effulgence26_mobile_app/features/event/domain/entities/event_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui'; // For BackdropFilter

import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
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
import '../../../../core/presentation/pages/pdf_viewer_page.dart';

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
    cubit.getMyJoinRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        child: BlocConsumer<EventsCubit, EventsState>(
          listener: (context, state) {
            if (state.selectedEvent != null) {
              setState(() => _event = state.selectedEvent);
            }

            if (state.successMessage != null) {
              _showSnackBar(state.successMessage!, AppColors.success);
              if (state.successMessage!.toLowerCase().contains('team created') && _isDialogVisible) {
                Navigator.of(context).pop();
                _isDialogVisible = false;
              }
              _loadData();
            }

            if (state.errorMessage != null && !state.isEventsLoading && !state.isDetailsLoading && !state.isOperationLoading) {
              if (_event != null) {
                String error = state.errorMessage!.contains("is not approved") 
                    ? "You Cannot Register for event until your profile is verified." 
                    : state.errorMessage!;
                if(!state.errorMessage!.contains("You are not part of any team")) {
                   _showSnackBar(error, AppColors.error);
                }
              }
            }

            if (state.myParticipations.isNotEmpty || (!state.isParticipationsLoading && state.myParticipations.isEmpty)) {
              setState(() {
                _registeredEventIds = state.myParticipations.map((p) => p.eventId).toList();
              });
            }
          },
          builder: (context, state) {
            if (state.isDetailsLoading && _event == null) {
              return const FullScreenLoading(message: 'Summoning event details...');
            }

            final event = _event;
            if (event != null) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildSliverAppBar(event),
                        SliverToBoxAdapter(
                          child: _buildContent(context, event, state),
                        ),
                        const SliverPadding(padding: EdgeInsets.only(bottom: 140)),
                      ],
                    ),
                  ),
                  _buildBottomActionOverlay(context, event, state),
                ],
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
      expandedHeight: 340,
      pinned: true,
      stretch: true,
       backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'event_card_${event.id}',
              child: UrlUtils.isValidUrl(event.coverImage)
                  ? CachedNetworkImage(
                      imageUrl: event.coverImage!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Image.asset(AppAssets.logoPng, fit: BoxFit.cover),
                    )
                  : Container(color: AppColors.bgSecondary, child: const Icon(Icons.event, size: 64)),
            ),
            // Improved Gradient Transition
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45, AppColors.bgPrimary],
                  stops: [0.4, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, EventEntity event, EventsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Identity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.domainName.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, letterSpacing: 2.0, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(event.title, style: AppTextStyles.headlineLarge.copyWith(height: 1.2, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              StatusBadge(status: event.status),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Event Type Chip (Solo/Team)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(event.isTeam ? Icons.groups_rounded : Icons.person_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(event.eventType, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          _buildInfoGrid(event),
          const SizedBox(height: AppSpacing.xl),
          _buildExternalLinks(event),
          
         // Description section
if (event.description != null && event.description!.isNotEmpty) ...[
            _buildSectionTitle('The Brief'),
            const SizedBox(height: AppSpacing.md),
            _buildGlassSection(
              child: Text(
                unescape.convert(event.description!),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.9),
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Rules section (The one you might have missed)
          if (event.rules != null && event.rules!.isNotEmpty) ...[
            _buildSectionTitle('Rules & Guidelines'),
            const SizedBox(height: AppSpacing.md),
            _buildGlassSection(
              child: Text(
                event.rules!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.8),
                  height: 1.6,
                ),
              ),
            ),
          ],
          if (event.contacts != null && event.contacts!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            _buildSectionTitle('Organizers'),
            const SizedBox(height: AppSpacing.md),
            _buildContactsList(event),
          ],
        ],
      ),
    );
  }

  Widget _buildGlassSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildInfoGrid(EventEntity event) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildGlassInfoCard(Icons.calendar_month_rounded, 'Date', event.eventTime.formattedDateTime, AppColors.electricBlue)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildGlassInfoCard(Icons.location_on_rounded, 'Venue', event.venue, AppColors.crimsonRed)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildGlassInfoCard(Icons.alarm_on_rounded, 'Registration Deadline', event.registrationDeadline.formattedDateTime, AppColors.secondary, isFullWidth: true),
        if (event.isTeam) ...[
          const SizedBox(height: AppSpacing.md),
          _buildGlassInfoCard(Icons.diversity_3_rounded, 'Squad Size', '${event.minTeamSize} to ${event.maxTeamSize} Members', AppColors.royalPurple, isFullWidth: true),
        ],
      ],
    );
  }

  Widget _buildGlassInfoCard(IconData icon, String title, String value, Color color, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1.1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildBottomActionOverlay(BuildContext context, EventEntity event, EventsState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary.withOpacity(0.8),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: _buildRegistrationActions(context, event, state),
          ),
        ),
      ),
    );
  }

  // Refined Registration Actions for UX clarity
  Widget _buildRegistrationActions(BuildContext context, EventEntity event, EventsState state) {
    if (!event.canRegister) {
       return Container(
         width: double.infinity,
         padding: const EdgeInsets.symmetric(vertical: 16),
         decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(12)),
         child: Center(child: Text(event.isCompleted ? 'EVENT ENDED' : 'REGISTRATION CLOSED', style: AppTextStyles.titleSmall.copyWith(color: AppColors.textDisabled))),
       );
    }

    if (_registeredEventIds.contains(event.id)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('CONGRATS! YOU\'RE IN', style: AppTextStyles.titleSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
            ],
          ),
          if (event.isTeam) ...[
            const SizedBox(height: 12),
            AppButton(
              text: 'MANAGE TEAM',
              icon: Icons.settings_suggest_rounded,
              backgroundColor: AppColors.secondary,
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => TeamManagementPage(eventId: event.id))).then((_) => _loadData()),
            ),
          ],
        ],
      );
    }

    if (event.isTeam) {
       return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GradientButton(
            text: 'CREATE TEAM',
            icon: Icons.add_moderator_rounded,
            isLoading: state.isOperationLoading,
            onPressed: () => _showTeamCreationDialog(context, event.id),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showPublicTeamsSheet(context, event),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('FIND TEAM'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyInvitationsPage())),
                  icon: const Icon(Icons.mail_outline, size: 18),
                  label: const Text('INVITES'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          )
        ],
      );
    }

    return GradientButton(
      text: 'REGISTER NOW',
      icon: Icons.bolt_rounded,
      isLoading: state.isOperationLoading,
      onPressed: () => context.read<EventsCubit>().registerForEvent(event.id),
    );
  }

  Widget _buildContactsList(EventEntity event) {
    return Column(
      children: event.contacts!.map((contact) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.2), child: const Icon(Icons.person, color: AppColors.primary)),
          title: Text(contact.name, style: AppTextStyles.titleMedium),
          subtitle: Text(contact.post ?? 'Coordinator', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          trailing: IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
            onPressed: () => _launchUrl('tel:${contact.number}'),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildExternalLinks(EventEntity event) {
    bool hasRulebook = event.rulebookPdf?.isNotEmpty ?? false;
    bool hasWhatsapp = event.whatsappGroupLink?.isNotEmpty ?? false;

    if (!hasRulebook && !hasWhatsapp) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Resources'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            if (hasRulebook) Expanded(child: _buildLinkButton(text: 'RULEBOOK', icon: Icons.picture_as_pdf_rounded, color: AppColors.primary, onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerPage(url: event.rulebookPdf!, title: 'Rulebook'),
                ),
              );
            })),
            if (hasRulebook && hasWhatsapp) const SizedBox(width: 12),
            if (hasWhatsapp) Expanded(child: _buildLinkButton(text: 'WHATSAPP', icon: Icons.wechat_rounded, color: const Color(0xFF25D366), onPressed: () => _launchUrl(event.whatsappGroupLink!))),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildLinkButton({required String text, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(text, style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Reuse your existing dialog/sheet methods...
  void _showTeamCreationDialog(BuildContext context, String eventId) {
    final eventsCubit = context.read<EventsCubit>();
    _isDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => BlocProvider.value(
        value: eventsCubit,
        child: TeamCreationDialogContent(
          eventId: eventId,
          teamNameController: TextEditingController(),
          eventsCubit: eventsCubit,
          onClose: () { Navigator.pop(dCtx); _isDialogVisible = false; },
        ),
      ),
    );
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar('Could not open link', AppColors.error);
    }
  }
}