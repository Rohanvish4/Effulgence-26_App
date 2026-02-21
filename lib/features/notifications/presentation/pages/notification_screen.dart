import 'package:effulgence26_mobile_app/core/services/remote_config_service.dart';
import 'package:effulgence26_mobile_app/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../components/common/particle_background.dart';
import '../../../../components/common/effulgence_background_elements.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';
import '../../domain/entities/notification_entity.dart';
import 'package:go_router/go_router.dart';
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _showReadHistory = false;

  @override
  void initState() {
    super.initState();
    // Trigger fetch on init
    context.read<NotificationCubit>().getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(context),
        ),  
        title: Text(
          'NOTIFICATIONS',
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
        actions: [
          IconButton(
            icon: Icon(
              _showReadHistory ? Icons.visibility_off : Icons.history,
            ),
            tooltip: _showReadHistory ? 'Hide history' : 'Show history',
            onPressed: () {
              setState(() {
                _showReadHistory = !_showReadHistory;
              });
            },
          ),

          IconButton(
            icon: const Icon(Icons.playlist_add_check_rounded),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationCubit>().markAllNotificationsRead();
            },
          ),
        ],
      ),
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.error.withValues(alpha:0.8), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<NotificationCubit>().getNotifications(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is NotificationLoaded) {

               final remoteConfig = context.read<RemoteConfigService>();
              final cutoffDate = DateTime.now().subtract(Duration(hours: remoteConfig.notificationExpiryTime));
              final validNotifications = state.notifications
                  .where((n) => n.createdAt.isAfter(cutoffDate));

              final notifications = _showReadHistory
                  ? validNotifications.toList()
                  : validNotifications.where((n) => !n.isRead).toList();

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha:0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha:0.2)),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.textMuted.withValues(alpha:0.5),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ALL CAUGHT UP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No new notifications at the moment.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<NotificationCubit>().getNotifications(),
                color: AppColors.primary,
                backgroundColor: AppColors.bgSecondary,
                edgeOffset: 100,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _NotificationItem(notification: notification);
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {

    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check_circle_outline, color: AppColors.primary),
      ),
      onDismissed: (_) {
        context.read<NotificationCubit>().markNotificationRead(notification.id);
      },
      confirmDismiss: (direction) async {
        if (isUnread) {
          context
              .read<NotificationCubit>()
              .markNotificationRead(notification.id);
          return false; // Don't actually remove from list, just mark read
        }
        return false;
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primary.withValues(alpha:0.05)
              : AppColors.surface.withValues(alpha:0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha:0.3)
                : AppColors.border.withValues(alpha:0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Mark as read if unread
                  // if (isUnread) {
                  //   context
                  //       .read<NotificationCubit>()
                  //       .markNotificationRead(notification.id);
                  // }
                  
                  // Handle navigation based on type and relatedId
                  if (notification.relatedId != null && 
                      notification.relatedId!.isNotEmpty) {
                    
                    final relatedId = notification.relatedId!;
                    
                    switch (notification.type.toUpperCase()) {
                      case 'EVENT':
                        // Mark as read if unread
                        if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        } 
                        context.pushNamed('eventDetails', pathParameters: {'id': relatedId});
                        break;
                      case 'TEAM_INVITE':
                         if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        } 
                        context.pushNamed('myInvitations');
                        break;
                      case 'TEAM_REQUEST':
                         if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        } 
                        context.pushNamed('teamManagement', pathParameters: {'eventId': relatedId});
                        break;
                      case 'TEAM_UPDATE':
                         if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        } 
                        // Team update can go to event details or team management
                        context.pushNamed('eventDetails', pathParameters: {'id': relatedId});
                        break;
                      case 'ADMIN':
                      case 'ALERT':
                      case 'REMINDER':
                      case 'SYSTEM':
                        // No navigation for admin/system notifications
                        break;
                      default:
                        // Unknown type or no specific navigation
                        break;
                    }
                  } else {
                     // If no relatedId but is team invite, still go to invitations
                     if (notification.type.toUpperCase() == 'TEAM_INVITE') {
                        if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        } 
                        context.pushNamed('myInvitations');
                     }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIcon(notification.type),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: isUnread
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: isUnread
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isUnread)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.message,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isUnread
                                    ? AppColors.textSecondary
                                    : AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              notification.createdAt.formattedDateTime,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textMuted.withValues(alpha:0.6),
                                fontSize: 10,
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
        ),
      ),
    );
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type.toUpperCase()) {
      case 'EVENT':
        iconData = Icons.event_available_rounded;
        color = const Color(0xFF6C63FF); // Purple
        break;
      case 'ADMIN':
        iconData = Icons.admin_panel_settings_rounded;
        color = const Color(0xFF00B894); // Green
        break;
      case 'ALERT':
        iconData = Icons.warning_rounded;
        color = const Color(0xFFFF7675); // Red
        break;
      case 'REMINDER':
        iconData = Icons.alarm_rounded;
        color = const Color(0xFFFFB74D); // Orange
        break;
      case 'SYSTEM':
        iconData = Icons.settings_rounded;
        color = const Color(0xFF2DD4BF); // Teal
        break;
      case 'TEAM_INVITE':
      case 'TEAM_REQUEST':
      case 'TEAM_UPDATE':
        iconData = Icons.people_outline_rounded;
        color = const Color(0xFFF39C12); // Amber
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}
