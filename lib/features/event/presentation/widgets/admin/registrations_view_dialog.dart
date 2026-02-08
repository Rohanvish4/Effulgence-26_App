import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/event_entity.dart';
import '../../cubit/events_cubit.dart';
import '../../cubit/events_state.dart';

class RegistrationsViewDialog extends StatefulWidget {
  final EventEntity event;

  const RegistrationsViewDialog({super.key, required this.event});

  @override
  State<RegistrationsViewDialog> createState() =>
      _RegistrationsViewDialogState();
}

class _RegistrationsViewDialogState extends State<RegistrationsViewDialog> {
  @override
  void initState() {
    super.initState();
    // Load registrations when dialog opens
    context.read<EventsCubit>().loadEventRegistrations(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSecondary,
      title: Text(
        'Registrations for ${widget.event.title}',
        style: AppTextStyles.headlineSmall,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Fixed height for list
        child: BlocBuilder<EventsCubit, EventsState>(
          builder: (context, state) {
            if (state.isOperationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Using myParticipations as a temporary holder for loaded registrations
            // since EventsCubit.loadEventRegistrations updates myParticipations
            // This is a bit of a hack re-using that field, but aligns with current cubit implementation
            final registrations = state.myParticipations;

            if (registrations.isEmpty) {
              return const Center(
                child: Text(
                  'No registrations found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return ListView.separated(
              itemCount: registrations.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.border),
              itemBuilder: (context, index) {
                final participation = registrations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha:0.2),
                    child: Text(
                      (participation.userName.isNotEmpty
                              ? participation.userName[0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ),
                  title: Text(
                    participation.userName,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participation.userEmail,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      if (participation.isTeam)
                        Text(
                          'Team: ${participation.teamName}',
                          style: const TextStyle(color: AppColors.accent),
                        ),
                    ],
                  ),
                  trailing: participation.isPresent
                      ? const Icon(Icons.check_circle, color: AppColors.success)
                      : null,
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
