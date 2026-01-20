import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../components/components.dart';
import '../cubit/events_cubit.dart';
import '../cubit/events_state.dart';

/// Team Creation Dialog Content - Stateful widget for public/private team selection
class TeamCreationDialogContent extends StatefulWidget {
  final String eventId;
  final TextEditingController teamNameController;
  final EventsCubit eventsCubit;
  final VoidCallback onClose;

  const TeamCreationDialogContent({
    super.key,
    required this.eventId,
    required this.teamNameController,
    required this.eventsCubit,
    required this.onClose,
  });

  @override
  State<TeamCreationDialogContent> createState() =>
      _TeamCreationDialogContentState();
}

class _TeamCreationDialogContentState extends State<TeamCreationDialogContent> {
  bool _isPublic = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        final isLoading = state is TeamCreationLoading;

        return AlertDialog(
          backgroundColor: AppColors.bgSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              const Icon(Icons.groups, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Create Team', style: AppTextStyles.titleMedium),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a creative name for your team.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: widget.teamNameController,
                enabled: !isLoading,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Team Name',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  hintText: 'e.g., Code Warriors',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.bgPrimary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Public/Private Team Toggle
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _isPublic
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPublic ? Icons.public : Icons.lock,
                          color: _isPublic
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _isPublic ? 'Public Team' : 'Private Team',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: _isPublic
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isPublic,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() => _isPublic = value);
                                },
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isPublic
                          ? 'Other users can find and join your team'
                          : 'Only invited members can join your team',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : widget.onClose,
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            AppButton(
              text: 'Create',
              icon: Icons.check,
              isLoading: isLoading,
              height: 40,
              isFullWidth: false,
              onPressed: () {
                final teamName = widget.teamNameController.text.trim();
                if (teamName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a team name'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                // Don't pop here; let the listener in the parent page handle success
                widget.eventsCubit.createTeam(
                  eventId: widget.eventId,
                  teamName: teamName,
                  isPublic: _isPublic,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
