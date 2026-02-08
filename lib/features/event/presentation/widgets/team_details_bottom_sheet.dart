import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/public_team_entity.dart';
import '../../../../components/common/team_member_avatar.dart';
import '../../../../components/buttons/app_button.dart';

/// Team Details Bottom Sheet
/// Shows detailed information about a public team and its members
/// Allows users to review team composition before joining
class TeamDetailsBottomSheet extends StatelessWidget {
  final PublicTeamEntity team;
  final int maxTeamSize;
  final bool isLoading;
  final VoidCallback onJoin;

  const TeamDetailsBottomSheet({
    super.key,
    required this.team,
    required this.maxTeamSize,
    this.isLoading = false,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = team.memberCount >= maxTeamSize;
    final availableSlots = maxTeamSize - team.memberCount;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgPrimary.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border(
                  top: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            _buildHeaderSection(context, isFull, availableSlots),

                            const SizedBox(height: AppSpacing.xxl),

                            // Team Info Cards
                            _buildInfoCards(isFull, availableSlots),

                            const SizedBox(height: AppSpacing.xxl),

                            // Team Members Section
                            _buildTeamMembersSection(),

                            const SizedBox(height: AppSpacing.xxl),

                            // Join Button
                            if (!isFull)
                              GradientButton(
                                text: 'JOIN TEAM',
                                icon: Icons.person_add,
                                isLoading: isLoading,
                                onPressed: onJoin,
                              )
                            else
                              AppButton(
                                text: 'TEAM FULL',
                                onPressed: null,
                                isFullWidth: true,
                                backgroundColor: AppColors.error.withValues(
                                  alpha: 0.1,
                                ),
                                textColor: AppColors.error,
                              ),

                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    bool isFull,
    int availableSlots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Team Details',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isFull ? AppColors.error : AppColors.success)
                        .withValues(alpha: 0.2),
                    (isFull ? AppColors.error : AppColors.success)
                        .withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: (isFull ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFull ? Icons.cloud_circle : Icons.check_circle,
                    color: isFull ? AppColors.error : AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFull ? 'FULL' : 'OPEN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isFull ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Created on ${_formatDate(team.registeredAt)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(bool isFull, int availableSlots) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.groups,
                label: 'Members',
                value: '${team.memberCount}/$maxTeamSize',
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.person_add,
                label: 'Available Slots',
                value: availableSlots.toString(),
                color: isFull ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'TEAM MEMBERS (${team.memberCount})',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: team.members.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final member = team.members[index];
            return _buildMemberCard(member, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(TeamMemberEntity member, int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Member Number Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Member Avatar
          TeamMemberAvatar(
            initials: member.initials,
            size: 40,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.md),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _hideEmail(member.email),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // User ID (for verification)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Tooltip(
              message: member.userId,
              child: Text(
                _truncateId(member.userId),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hide email by showing only first character and domain
  String _hideEmail(String? email) {
    if (email == null || email.isEmpty) return 'No email';
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.isEmpty) return '***@$domain';
    return '${username[0]}${'*' * (username.length - 1)}@$domain';
  }

  /// Truncate ID for display (show first 8 chars)
  String _truncateId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}...';
  }

  /// Format date to readable format
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
