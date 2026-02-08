import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../features/event/domain/entities/public_team_entity.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../common/team_member_avatar.dart';
import '../buttons/app_button.dart';

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

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg),
          ),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: AppColors.bgPrimary.withValues(alpha: 0.95),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Header with drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Team Header Section
                  _buildHeaderSection(isFull),
                  const SizedBox(height: AppSpacing.lg),

                  // Info Cards
                  _buildInfoCards(isFull),
                  const SizedBox(height: AppSpacing.lg),

                  // Team Members Section
                  _buildTeamMembersSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Join Button
                  AppButton(
                    text: isFull ? 'Team Full' : 'Join Team',
                    icon: isFull ? Icons.block : Icons.group_add,
                    isLoading: isLoading,
                    onPressed: isFull ? null : onJoin,
                    backgroundColor: isFull
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    textColor:
                        isFull ? AppColors.error : AppColors.success,
                    height: 48,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(bool isFull) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created on ${_formatDate(team.registeredAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isFull
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isFull
                      ? AppColors.error.withValues(alpha: 0.3)
                      : AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isFull ? Icons.lock : Icons.lock_open,
                    color: isFull ? AppColors.error : AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFull ? 'FULL' : 'OPEN',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isFull ? AppColors.error : AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCards(bool isFull) {
    final availableSlots = (maxTeamSize - team.memberCount).clamp(0, maxTeamSize);

    return Row(
      children: [
        // Member Count Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Members',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${team.memberCount}',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'of $maxTeamSize',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Available Slots Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  (isFull ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.1),
                  (isFull ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFull ? Icons.block : Icons.check_circle,
                      color: isFull ? AppColors.error : AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Available',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$availableSlots',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFull ? AppColors.error : AppColors.success,
                  ),
                ),
                Text(
                  'slot${availableSlots == 1 ? '' : 's'}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMembersSection() {
    if (team.members.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            'No members yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Members',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: team.members.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final member = team.members[index];
            return _buildMemberCard(context, member, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, TeamMemberEntity member, int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Index Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                   AppColors.primary,
                
                ]
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Member Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  member.name,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Hidden Email
                Text(
                  _hideEmail(member.email),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Truncated User ID with tooltip
                Tooltip(
                  message: member.userId,
                  child: Text(
                    _truncateId(member.userId),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar
          if (member.imageUrl != null)
          TeamMemberAvatar(
            imageUrl: member.imageUrl,
            initials: member.initials,
            size: 44,
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _hideEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'No email provided';
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return email;
    }

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 1) {
      return '${username[0]}***@$domain';
    }

    final firstChar = username[0];
    final asterisks = '*' * (username.length - 1);
    return '$firstChar$asterisks@$domain';
  }

  String _truncateId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return '${id.substring(0, 8)}...';
  }

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
