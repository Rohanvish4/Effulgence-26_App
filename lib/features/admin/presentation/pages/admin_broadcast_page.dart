import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../components/common/particle_background.dart';
import '../../../../components/common/effulgence_background_elements.dart';
import '../../../event/presentation/cubit/events_cubit.dart';
import '../../../event/presentation/cubit/events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BroadcastTarget { allUsers, internalUsers, externalUsers }

class AdminBroadcastPage extends StatefulWidget {
  const AdminBroadcastPage({super.key});

  @override
  State<AdminBroadcastPage> createState() => _AdminBroadcastPageState();
}

class _AdminBroadcastPageState extends State<AdminBroadcastPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _relatedIdController = TextEditingController();
  BroadcastTarget _selectedTarget = BroadcastTarget.allUsers;
  String _selectedType = 'ADMIN';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _relatedIdController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = context.read<ApiClient>();
      
      // Determine target type for backend filtering
      String targetType;
      switch (_selectedTarget) {
        case BroadcastTarget.allUsers:
          targetType = 'ALL';
          break;
        case BroadcastTarget.internalUsers:
          targetType = 'INTERNAL';
          break;
        case BroadcastTarget.externalUsers:
          targetType = 'EXTERNAL';
          break;
      }

      await apiClient.sendBroadcast(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        targetType: targetType,
        type: _selectedType,
        relatedId: _relatedIdController.text.trim().isNotEmpty 
            ? _relatedIdController.text.trim() 
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Broadcast sent to ${_getTargetLabel(_selectedTarget)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00B894),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _titleController.clear();
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getTargetLabel(BroadcastTarget target) {
    switch (target) {
      case BroadcastTarget.allUsers:
        return 'All Users';
      case BroadcastTarget.internalUsers:
        return 'Internal Users (KNIT)';
      case BroadcastTarget.externalUsers:
        return 'External Users';
    }
  }

  IconData _getTargetIcon(BroadcastTarget target) {
    switch (target) {
      case BroadcastTarget.allUsers:
        return Icons.groups_rounded;
      case BroadcastTarget.internalUsers:
        return Icons.school_rounded;
      case BroadcastTarget.externalUsers:
        return Icons.public_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'BROADCAST',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgPrimary.withValues(alpha:0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Send Notification',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Broadcast messages to app users',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Target Selection
                  Text(
                    'TARGET AUDIENCE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: BroadcastTarget.values.map((target) {
                      final isSelected = _selectedTarget == target;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: target != BroadcastTarget.externalUsers ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTarget = target),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha:0.15)
                                    : AppColors.surface.withValues(alpha:0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border.withValues(alpha:0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _getTargetIcon(target),
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    target == BroadcastTarget.allUsers
                                        ? 'All'
                                        : target == BroadcastTarget.internalUsers
                                            ? 'Internal'
                                            : 'External',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Notification Type Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Notification Type',
                      filled: true,
                      fillColor: AppColors.surface.withValues(alpha:0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: ['ADMIN', 'EVENT', 'REMINDER', 'SYSTEM']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                           _selectedType = value;
                           // Clear related ID when type changes to avoid confusion
                           _relatedIdController.clear();
                        });
                        if (value == 'EVENT') {
                          context.read<EventsCubit>().loadEvents();
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Title Field
                  _buildTextField(
                    controller: _titleController,
                    label: 'Notification Title',
                    hint: 'Enter a catchy title',
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.length > 100) {
                        return 'Title too long (max 100 chars)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message Field
                  _buildTextField(
                    controller: _messageController,
                    label: 'Message',
                    hint: 'Write your notification message...',
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Message is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Related ID Section
                  if (_selectedType == 'EVENT')
                    BlocBuilder<EventsCubit, EventsState>(
                      builder: (context, state) {
                        if (state.isEventsLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        
                        // Create a map of events for easy lookup
                        final events = state.events;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              dropdownColor: AppColors.surface,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Select Event',
                                filled: true,
                                fillColor: AppColors.surface.withValues(alpha:0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              items: events.map((event) {
                                return DropdownMenuItem<String>(
                                  value: event.id,
                                  child: Text(
                                    event.title,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _relatedIdController.text = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 8),
                            // Hidden or read-only field to show the actual ID being sent
                             _buildTextField(
                              controller: _relatedIdController,
                              label: 'Event ID (Auto-filled)',
                              hint: 'Selected event ID',
                              maxLines: 1,
                              validator: (value) => null,
                              enabled: false, // Read-only
                            ),
                          ],
                        );
                      },
                    )
                  else
                    // Standard Manual Entry for other types
                    _buildTextField(
                      controller: _relatedIdController,
                      label: 'Related ID (Optional)',
                      hint: 'e.g., User ID',
                      maxLines: 1,
                      validator: (value) => null,
                    ),
                  const SizedBox(height: 32),

                  // Send Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendBroadcast,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Send to ${_getTargetLabel(_selectedTarget)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    required String? Function(String?) validator,
    bool enabled = true,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(color: AppColors.textPrimary),
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            alignLabelWithHint: maxLines > 1,
            labelStyle: TextStyle(color: AppColors.textMuted),
            hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha:0.5)),
            filled: true,
            fillColor: AppColors.surface.withValues(alpha:0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error.withValues(alpha:0.5)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
