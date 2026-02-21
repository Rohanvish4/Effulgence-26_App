import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:effulgence26_mobile_app/core/constants/app_env.dart';
import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';

import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_cubit.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/cubit/events_state.dart';
import 'package:effulgence26_mobile_app/features/home/presentation/widgets/home_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:effulgence26_mobile_app/core/services/remote_config_service.dart';
import 'package:effulgence26_mobile_app/core/services/analytics_service.dart';
import '../../../../../components/components.dart';

import 'package:effulgence26_mobile_app/features/home/presentation/widgets/countdown_timer_widget.dart';
import 'package:effulgence26_mobile_app/features/home/presentation/widgets/faq_widget.dart';


import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_assets.dart';

/// Home Tab with overview and quick actions
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final CarouselController _carouselController = CarouselController();
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  // Keep state alive to prevent rebuilds when switching tabs
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int itemCount) {
    if (itemCount <= 1) return; // No need to auto-scroll if 1 or fewer items

    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      _carouselIndex = (_carouselIndex + 1) % itemCount;

      try {
        _carouselController.animateToItem(
          _carouselIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        debugPrint('Auto-scroll error: $e');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Track screen view in analytics
    AnalyticsService.instance.logScreenView(screenName: 'HomePage');
    
    // Use addPostFrameCallback to ensure context is fully ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
// Auth check removed to prevent state flicker (handled in AppProviders)
      // Load events on home tab (will be filtered in UI)
      context.read<EventsCubit>().loadEvents(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.dense,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            _buildRemoteConfigBanner(context),
            _buildWelcomeSection(),
            // _buildQuickStats(),
            _buildHighlightsCarousel(),
            _buildBattlefieldsSection(),
            _buildAboutSection(),
             const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: FaqWidget(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            _buildInnovationSection(),  
          ],
        ),
      ),
    );

  }

  // Remote Config Banner
  Widget _buildRemoteConfigBanner(BuildContext context) {
    try {
      final remoteConfig = context.read<RemoteConfigService>();
      if (!remoteConfig.isHomeBannerVisible) return const SliverToBoxAdapter(child: SizedBox.shrink());
      print("remoteConfig.homeBannerText ");
      print(remoteConfig.homeBannerText);

      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.campaign_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    remoteConfig.homeBannerText,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Fail silently if provider not found (shouldn't happen)
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  // App Bar
  Widget _buildAppBar() {
    return SliverAppBar(
      actions: [IconButton(
        icon: const Icon(Icons.notifications_rounded, color: AppColors.primary),
        onPressed: () {
          HapticFeedback.vibrate();
          context.push('/notifications');
        },
      ),],
      expandedHeight: 220,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
        onPressed: () {
          Hometab.of(context)?.toggleDrawer();
          HapticFeedback.vibrate();
        },
      ),      
      backgroundColor: Colors.transparent, // Transparent to show particles
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgPrimary.withValues(alpha: 0.8),
                AppColors.bgPrimary.withValues(alpha: 0.0),
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
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppColors.primaryGlow(
                          opacity: 0.1,
                          blur: 40,
                          ),
                      ),
                      child: Image.asset(
                        AppAssets.logoPng,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SvgPicture.asset(AppAssets.textSvg, width: 200),
                    const SizedBox(height: AppSpacing.xs),

                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Lightning decoration
                        Positioned(
                          left: -60,
                          child: SvgPicture.asset(
                            AppAssets.lightningLeftSvg,
                            height: 80,
                            colorFilter: const ColorFilter.mode(
                                AppColors.primary, BlendMode.srcIn),
                          ),
                        ),
                        Positioned(
                          right: -60,
                          child: SvgPicture.asset(
                            AppAssets.lightningRightSvg,
                            height: 80,
                            colorFilter: const ColorFilter.mode(
                                AppColors.primary, BlendMode.srcIn),
                          ),
                        ),

                        Text(
                          'INNOVATION AND BEYOND',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                    const CountdownTimerWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Highlights Carousel with Event Cards
  Widget _buildHighlightsCarousel() {
    return BlocConsumer<EventsCubit, EventsState>(
      listener: (context, state) {
        if (state.status == EventsStatus.success) {
          final highlightedEvents = state.events.take(5).toList();
          if (highlightedEvents.isNotEmpty) {
            _startAutoScroll(highlightedEvents.length);
          }
        }
      },
      builder: (context, state) {
        // Show shimmer if loading OR if we have no events yet (initial state)
        if (state.isEventsLoading || (state.events.isEmpty && state.errorMessage == null)) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: SizedBox(
                height: 240, // Match Carousel height
                child: ShimmerCard(
                  width: double.infinity,
                  height: 240,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          );
        }

        if (state.errorMessage != null && state.events.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        if (state.events.isNotEmpty) {
          final highlightedEvents = state.events.take(5).toList();

          if (highlightedEvents.isEmpty) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(width: 3, height: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        "HIGHLIGHTS",
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: SizedBox(
                    height: 240,
                    child: CarouselView(
                      controller: _carouselController,
                      itemSnapping: true,
                      itemExtent: 320.0,
                      shrinkExtent: 220.0,
                      onTap: (index) async {
                        await context.push(
                          '/events/${highlightedEvents[index].id}',
                        );
                        if (context.mounted) {
                          context.read<EventsCubit>().loadEvents(refresh: true);
                        }
                      },
                      children: List.generate(
                        highlightedEvents.length,
                        (index) =>
                            _buildCarouselEventCard(highlightedEvents[index]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // Carousel Event Card
  Widget _buildCarouselEventCard(event) {
    return GestureDetector(
      onTap: () async {
        await context.push('/events/${event.id}');
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          context.read<EventsCubit>().loadEvents(refresh: true);
        }
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Event Image
            if (UrlUtils.isValidUrl(event.coverImage))
              CachedNetworkImage(
                        imageUrl: event.coverImage!,
                        fit: BoxFit.cover,
                        // Memory cache configuration
                        memCacheHeight: 300,
                        memCacheWidth: 600,
                        // Aggressive caching
                        maxHeightDiskCache: 400,
                        maxWidthDiskCache: 800,
                        placeholder: (context, url) => Container(
                          color: AppColors.bgSecondary.withValues(alpha: 0.5),
                          child: Center(
                            child: Image.asset(
                              AppAssets.logoPng,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.bgSecondary),
                      )
            else
              Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.event,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
              ),

            // Gradient Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event.domainName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status Badge
            Positioned(
              top: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(event.status).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Text(
                  event.status,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Welcome Section
  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String userName = 'Guest';
            if (state is AuthAuthenticated) {
              userName = state.user.name.split(' ').first;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome, ",
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text:
                                "${userName[0].toUpperCase() + userName.substring(1)}",
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    );
  }

  // Quick Stats
  // Widget _buildQuickStats() {
  //   return SliverToBoxAdapter(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  //       child: BlocBuilder<EventsCubit, EventsState>(
  //         builder: (context, state) {
  //           int totalEvents = 50;
  //           int upcomingCount = 0;

  //           if (state.events.isNotEmpty) {
  //             totalEvents = state.events.length;
  //             upcomingCount = state.events
  //                 .where((e) => e.status == 'UPCOMING')
  //                 .length;
  //           }

  //           return Row(
  //             children: [
  //               Expanded(
  //                 child: _buildStatCard(
  //                   icon: Icons.event,
  //                   title: 'Events',
  //                   value: '60+',
  //                   color: AppColors.primary,
  //                 ),
  //               ),
  //               const SizedBox(width: AppSpacing.md),
  //               Expanded(
  //                 child: _buildStatCard(
  //                   icon: Icons.upcoming,
  //                   title: 'Upcoming',
  //                   value: '30+',
  //                   color: AppColors.secondary,
  //                 ),
  //               ),
  //               const SizedBox(width: AppSpacing.md),
  //               Expanded(
  //                 child: _buildStatCard(
  //                   icon: Icons.people,
  //                   title: 'Participants',
  //                   value: '3000+',
  //                   color: AppColors.accent,
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStatCard({
  //   required IconData icon,
  //   required String title,
  //   required String value,
  //   required Color color,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.all(AppSpacing.md),
  //     decoration: BoxDecoration(
  //       color: AppColors.surface,
  //       borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  //       border: Border.all(color: AppColors.border),
  //     ),
  //     child: Column(
  //       children: [
  //         Icon(icon, color: color, size: 28),
  //         const SizedBox(height: AppSpacing.xs),
  //         Text(
  //           value,
  //           style: AppTextStyles.titleLarge.copyWith(
  //             color: color,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         Text(
  //           title,
  //           style: AppTextStyles.labelSmall,
  //           maxLines: 1,
  //           overflow: TextOverflow.ellipsis,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Upcoming Events Header

  // Events List

  // Error State

  // Empty State

  Widget _buildInnovationSection() {
    final List<Map<String, String>> features = [
      {
        "title": "ROBOTICS CLUB",
        "desc":
            "Leads robotics, automation, embedded systems, and hardware innovation."
      },
      {
        "title": "PTSC",
        "desc":
            "The nucleus for competitive programming and full stack development."
      },
      {
        "title": "IISF",
        "desc": "Startup ecosystem enabling founders to transform ideas."
      },
      {
        "title": "MEF",
        "desc": "Focused on mechanical design and manufacturing challenges."
      },
      {
        "title": "ESPORTS",
        "desc": "Organizes competitive gaming tournaments and events."
      },
      {
        "title": "FORONIX",
        "desc": "Multidisciplinary tech community emphasizing electronics and IoT."
      },
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Container(width: 3, height: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  "POWERED BY INNOVATION",
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140, // Height for the horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final item = features[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            item["title"]!,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["desc"]!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildBattlefieldsSection() {
    final List<Map<String, dynamic>> battlefields = [
      {
        "icon": Icons.precision_manufacturing_rounded,
        "title": "Robotics",
        "desc":
            "Autonomous robotics, Robo-Wars, and intelligent machines engineered for high stakes."
      },
      {
        "icon": Icons.code_rounded,
        "title": "Programming",
        "desc":
            "Competitive coding, hackathons, and full stack development challenges."
      },
      {
        "icon": Icons.business_center_rounded,
        "title": "Entrepreneurial",
        "desc":
            "Management and entrepreneurial simulations including business plans."
      },
      {
        "icon": Icons.architecture_rounded,
        "title": "Miscellaneous",
        "desc": "Mechanical and civil engineering design challenges."
      },
      {
        "icon": Icons.sports_esports_rounded,
        "title": "Esports",
        "desc": "Competitive gaming tournaments featuring popular titles."
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            children: [
              Container(width: 3, height: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "THE BATTLEFIELDS",
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...battlefields.map((item) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item["icon"] as IconData,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["title"] as String,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item["desc"] as String,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }

  Widget _buildAboutSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.surface.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROTOCOL: EFFULGENCE',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Effulgence '26 is the premier technical symposium of KNIT Sultanpur. Join a network of visionaries for a three-day intensive of high-stakes competition.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    launchUrl(Uri.parse(AppEnv.websiteBaseUrl));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'VIEW MANIFESTO',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_outward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
