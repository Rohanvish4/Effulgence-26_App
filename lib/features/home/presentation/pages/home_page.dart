import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_cubit.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Home Tab with overview and quick actions
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().getCurrentUser();
      // Load events on home tab (will be filtered in UI)
      context.read<EventsCubit>().loadEvents(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //it is added temp to check logot
      floatingActionButton: ElevatedButton(
        onPressed: () {
          context.read<AuthCubit>().logout();
        },
        child: const Text('Log out'),
      ),
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            // actions: [
            //   ElevatedButton(
            //     onPressed: () {
            //       context.read<AuthCubit>().logout();
            //     },
            //     child: const Text('Log out'),
            //   ),
            // ],
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogo(size: 50),
                          const SizedBox(height: AppSpacing.md),
                          GradientText(
                            text: "EFFULGENCE '26",
                            style: AppTextStyles.displayMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'The Annual Tech Fest',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
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

          // Welcome Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  String userName = 'Guest';
                  if (state is AuthAuthenticated) {
                    userName = state.user.name.split(' ').first;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $userName! 👋',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Explore events and participate in exciting competitions.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Quick Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.event,
                      title: 'Events',
                      value: '50+',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.category,
                      title: 'Domains',
                      value: '6',
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people,
                      title: 'Participants',
                      value: '3000+',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Upcoming Events Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Events', style: AppTextStyles.titleLarge),
                  TextButton(
                    onPressed: () {
                      context.push('/events');
                    },
                    child: Text(
                      'View All',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Events List
          BlocBuilder<EventsCubit, EventsState>(
            builder: (context, state) {
              if (state is EventsLoading) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: ShimmerCard(
                          width: 280,
                          height: 220,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (state is EventsLoaded) {
                // Client-side filtering for upcoming events
                final upcomingEvents = state.events
                    .where((e) => e.status == 'UPCOMING')
                    .take(5)
                    .toList();

                if (upcomingEvents.isNotEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 260,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        itemCount: upcomingEvents.length,
                        itemBuilder: (context, index) {
                          final event = upcomingEvents[index];
                          return Container(
                            width: 320,
                            margin: const EdgeInsets.only(right: AppSpacing.md),
                            child: EventCard(
                              title: event.title,
                              domain: event.domainName,
                              imageUrl: event.coverImage,
                              venue: event.venue,
                              dateTime: event.eventTime,
                              status: event.status,
                              onTap: () => context.push('/events/${event.id}'),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              }

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () {
                            context.read<EventsCubit>().loadEvents(
                              refresh: true,
                            );
                          },
                          child: Text(
                            'No upcoming events',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // About Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About Effulgence', style: AppTextStyles.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "Effulgence is the annual technical fest of KNIT Sultanpur. It brings together tech enthusiasts from across the country for competitions, workshops, and exhibitions.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GradientButton(
                      text: 'LEARN MORE',
                      onPressed: () {
                        // Navigate to about page or website
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
