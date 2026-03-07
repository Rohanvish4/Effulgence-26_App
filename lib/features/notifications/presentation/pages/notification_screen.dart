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
import 'package:badges/badges.dart' as badges;

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
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            int unreadCount = 0;
            List<NotificationEntity> allValidNotifications = [];

            if (state is NotificationLoaded) {
              final remoteConfig = context.read<RemoteConfigService>();
              final cutoffDate = DateTime.now().subtract(
                Duration(hours: remoteConfig.notificationExpiryTime),
              );
              allValidNotifications = state.notifications
                  .where((n) => n.createdAt.isAfter(cutoffDate))
                  .toList();
              unreadCount =
                  allValidNotifications.where((n) => !n.isRead).length;
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildSliverAppBar(unreadCount),
                if (state is NotificationLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (state is NotificationError)
                  SliverFillRemaining(
                    child: _buildErrorState(state.message),
                  )
                else if (state is NotificationLoaded)
                  ..._buildLoadedContent(allValidNotifications),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(int unreadCount) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () => context.pop(context),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: const EdgeInsets.only(bottom: 16),
            title: badges.Badge(
              showBadge: unreadCount > 0,
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(4),
              ),
              badgeContent: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              position: badges.BadgePosition.topEnd(top: -12, end: -15),
              child: Text(
                'NOTIFICATIONS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bgPrimary.withValues(alpha: 0.8),
                    AppColors.bgPrimary.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.done_all_rounded, color: AppColors.primary, size: 20),
          ),
          tooltip: 'Mark all as read',
          onPressed: () {
            context.read<NotificationCubit>().markAllNotificationsRead();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: AppColors.error.withValues(alpha: 0.8), size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<NotificationCubit>().getNotifications(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoadedContent(List<NotificationEntity> validNotifications) {
    final notifications = _showReadHistory
        ? validNotifications
        : validNotifications.where((n) => !n.isRead).toList();

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: _buildFilterToggle(),
        ),
      ),
      if (notifications.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationItem(notification: notification),
                );
              },
              childCount: notifications.length,
            ),
          ),
        ),
    ];
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showReadHistory = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_showReadHistory
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: !_showReadHistory
                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                      : Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    'Unread',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: !_showReadHistory
                          ? AppColors.primary
                          : AppColors.textMuted,
                      fontWeight: !_showReadHistory ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showReadHistory = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _showReadHistory
                      ? AppColors.surface.withValues(alpha: 0.5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: _showReadHistory
                      ? Border.all(color: AppColors.border.withValues(alpha: 0.2))
                      : Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    'History',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: _showReadHistory
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: _showReadHistory ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Icon(
                    _showReadHistory ? Icons.inbox_rounded : Icons.notifications_active_outlined,
                    color: AppColors.primary.withValues(alpha: 0.6),
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            _showReadHistory ? 'NO NOTIFICATIONS' : 'ALL CAUGHT UP',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _showReadHistory
                ? 'You have no notifications yet.'
                : 'No new notifications at the moment.\nCheck history for older ones.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
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
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Mark as read',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_outline, color: AppColors.primary),
          ],
        ),
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
          gradient: LinearGradient(
            colors: isUnread
                ? [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.02),
                  ]
                : [
                    AppColors.surface.withValues(alpha: 0.4),
                    AppColors.surface.withValues(alpha: 0.2),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.08),
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (notification.relatedId != null &&
                      notification.relatedId!.isNotEmpty) {
                    final relatedId = notification.relatedId!;

                    switch (notification.type.toUpperCase()) {
                      case 'EVENT':
                        if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        }
                        context.pushNamed('eventDetails',
                            pathParameters: {'id': relatedId});
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
                        context.pushNamed('teamManagement',
                            pathParameters: {'eventId': relatedId});
                        break;
                      case 'TEAM_UPDATE':
                        if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        }
                        context.pushNamed('eventDetails',
                            pathParameters: {'id': relatedId});
                        break;
                      case 'ADMIN':
                      case 'ALERT':
                      case 'REMINDER':
                      case 'SYSTEM':
                        if (isUnread) {
                          context
                              .read<NotificationCubit>()
                              .markNotificationRead(notification.id);
                        }
                        break;
                      default:
                        break;
                    }
                  } else {
                    if (notification.type.toUpperCase() == 'TEAM_INVITE') {
                      if (isUnread) {
                        context
                            .read<NotificationCubit>()
                            .markNotificationRead(notification.id);
                      }
                      context.pushNamed('myInvitations');
                    } else if (isUnread) {
                      context
                          .read<NotificationCubit>()
                          .markNotificationRead(notification.id);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIcon(notification.type, isUnread),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: isUnread
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                if (isUnread)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8, top: 4),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.5, end: 1.0),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeInOutSine,
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary.withValues(alpha: 0.5 * value),
                                                blurRadius: 4 * value,
                                                spreadRadius: 1 * value,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
                                    : AppColors.textMuted.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: AppColors.textMuted.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  notification.createdAt.formattedDateTime,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textMuted.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
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

  Widget _buildIcon(String type, bool isUnread) {
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
        color = AppColors.primary; // Primary Color
        break;
      case 'TEAM_INVITE':
      case 'TEAM_REQUEST':
      case 'TEAM_UPDATE':
        iconData = Icons.people_alt_rounded;
        color = const Color(0xFFF39C12); // Amber
        break;
      default:
        iconData = Icons.notifications_rounded;
        color = AppColors.textSecondary;
    }

    if (!isUnread) {
      color = color.withValues(alpha: 0.5);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isUnread ? 0.15 : 0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: isUnread ? 0.3 : 0.1),
          width: 1,
        ),
      ),
      child: Icon(iconData, color: color, size: 22),
    );
  }
}
