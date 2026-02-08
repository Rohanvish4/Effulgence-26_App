import 'package:flutter/material.dart';
import '../../features/event/domain/entities/public_team_entity.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../buttons/app_button.dart';
import '../common/team_member_avatar.dart';

class TeamCard extends StatelessWidget {
  final PublicTeamEntity team;
  final int maxTeamSize;
  final bool isLoading;
  final VoidCallback onJoin;
  final VoidCallback? onViewDetails;

  const TeamCard({
    super.key,
    required this.team,
    required this.maxTeamSize,
    this.isLoading = false,
    required this.onJoin,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull = team.memberCount >= maxTeamSize;

    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
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
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created ${_formatDate(team.registeredAt)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isFull
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFull
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFull ? Icons.lock : Icons.lock_open,
                        size: 12,
                        color: isFull ? AppColors.error : AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${team.memberCount}/$maxTeamSize',
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
      
            // Members Row
            if (team.members.isNotEmpty)
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: team.members.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final member = team.members[index];
                    return _buildMemberAvatar(member);
                  },
                ),
              ),
      
            const SizedBox(height: AppSpacing.md),
      
            // Action Buttons Row
            Row(
              children: [
                // View Details Button
                // Expanded(
                //   child: AppButton(
                //     text: 'View Details',
                //     icon: Icons.info_outline,
                //     onPressed: onViewDetails,
                //     backgroundColor: AppColors.bgSecondary,
                //     textColor: AppColors.accent,
                //     height: 40,
                //   ),
                // ),
                // const SizedBox(width: AppSpacing.sm),
                // Join Button
                Expanded(
                  child: AppButton(
                    text: isFull ? 'Team Full' : 'Join Team',
                    icon: isFull ? Icons.block : Icons.group_add,
                    isLoading: isLoading,
                    onPressed: isFull ? null : onJoin,
                    backgroundColor: isFull
                        ? AppColors.bgSecondary
                        : AppColors.primary.withValues(alpha: 0.1),
                    textColor: isFull ? AppColors.textDisabled : AppColors.primary,
                    height: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(TeamMemberEntity member) {
    return TeamMemberAvatar(
      imageUrl: member.imageUrl,
      initials: member.initials,
      size: 40,
      backgroundColor: AppColors.primary,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
