import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:effulgence26_mobile_app/core/services/remote_config_service.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/pages/admin_events_page.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/pages/events_list_page.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/pages/user_profile_page.dart';
import 'package:effulgence26_mobile_app/features/sponsors/presentation/pages/sponsors_list_page.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import 'accommodation_reminder_dialog.dart';
import '../pages/home_page.dart';
import 'sidebar_menu.dart';

class Hometab extends StatefulWidget {
  const Hometab({super.key});

  static HometabState? of(BuildContext context) =>
      context.findAncestorStateOfType<HometabState>();

  @override
  State<Hometab> createState() => HometabState();
}

class HometabState extends State<Hometab> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _radiusAnimation;
  late PageController _pageController;
  bool _hasShownAccommodationReminder = false;

  // Drawer state
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 220.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutCubic),
    );
    
     _radiusAnimation = Tween<double>(begin: 0.0, end: 24.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutCubic),
    );

    _pageController = PageController(initialPage: _currentIndex);
    _pageController.addListener(_onPageChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowAccommodationReminder();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    if (_animationController.isDismissed) {
      _animationController.forward();
      setState(() => _isDrawerOpen = true);
    } else {
      _animationController.reverse();
      setState(() => _isDrawerOpen = false);
    }
  }

  void _onPageChanged() {
    final newIndex = _pageController.page?.round() ?? 0;
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  void closeDrawer() {
    HapticFeedback.vibrate();
     if (_animationController.isCompleted) {
      _animationController.reverse();
      setState(() => _isDrawerOpen = false);
    }
  }

  void goToProfileTab() {
    if (_currentIndex == 3 || !_pageController.hasClients) return;

    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _maybeShowAccommodationReminder() {
    if (_hasShownAccommodationReminder || !mounted) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;

    final remoteConfig = context.read<RemoteConfigService>();
    if (!remoteConfig.isAccommodationReminderVisible) return;

    final user = authState.user;
    final shouldShowReminder = !user.isInternalUser && !user.isApproved;
    if (!shouldShowReminder) return;

    _hasShownAccommodationReminder = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) {
        return AccommodationReminderDialog(
          deadline: remoteConfig.accommodationPaymentDeadline,
          onCompletePayment: goToProfileTab,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary, // Background for the sidebar
      body: Stack(
        children: [
        //Sidebar Menu (Bottom Layer)
    
           SidebarMenu(onClose: closeDrawer),

          // Main Content (Top Layer)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(_slideAnimation.value)
                  ..scale(_scaleAnimation.value),
                alignment: Alignment.centerLeft, // Pivot point for scaling
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_radiusAnimation.value),
                  child: Container(
                     // Add shadow for depth
                    decoration: BoxDecoration(
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withValues(alpha:0.5),
                          blurRadius: 30,
                          offset: const Offset(-20, 10),
                         )
                      ]
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: _buildMainContent(),
          ),
          
          // Click blocker for the main content when drawer is open
          if (_isDrawerOpen)
            GestureDetector(
              onTap: closeDrawer,
              child: AnimatedBuilder(
                animation: _animationController,
                 builder: (context, child) {
                   // Only block clicks on the visible part of the scaled screen
                   // This logic works because we are in a Stack. 
                   // But we need to make sure we don't block the sidebar.
                   return Transform(
                     transform: Matrix4.identity()
                      ..translate(_slideAnimation.value)
                      ..scale(_scaleAnimation.value),
                     alignment: Alignment.centerLeft,
                     child: Container(
                       color: Colors.transparent, 
                       width: MediaQuery.of(context).size.width,
                       height: MediaQuery.of(context).size.height,
                     ),
                   );
                 }
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isAdmin = state is AuthAuthenticated && state.user.isAdmin;

        final List<Widget> pages = [
          const HomePage(),
          const EventsListPage(),
          const SponsorsListPage(),
          const UserProfilePage(),
          if (isAdmin) const AdminEventsPage(),
        ];

        return Scaffold(
          extendBody: false,
          body: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: pages,
          ),
          bottomNavigationBar: _buildFloatingNavBar(isAdmin),
        );
      },
    );
  }

  Widget _buildFloatingNavBar(bool isAdmin) {
    return Container(
      height: 78,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.bgOverlay,
                AppColors.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.42),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                0,
                Icons.home_rounded,
                'Home',
                assetPath: 'assets/icons/home.png',
                selectedAssetPath: 'assets/icons/home_selected.png',
              ),
              _buildNavItem(1, Icons.bolt_rounded,assetPath: 'assets/icons/calendar.png', selectedAssetPath: 'assets/icons/calendar_selected.png', 'Events'),
              _buildNavItem(2, Icons.handshake_rounded, 'Partners'),
              _buildNavItem(
                3,
                Icons.person_rounded,
                'Profile',
                assetPath: 'assets/icons/profile.png',
                selectedAssetPath: 'assets/icons/profile_selected.png',
              ),
              if (isAdmin)
                _buildNavItem(4, Icons.admin_panel_settings_rounded,assetPath: 'assets/icons/admin.png', selectedAssetPath: 'assets/icons/admin_selected.png',   'Admin'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label, {
    String? assetPath,
    String? selectedAssetPath,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Animate to the selected page
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            scale: isSelected ? 1.05 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 0.8,
                      )
                    : null,
              ),
              child: assetPath != null
                  ? Image.asset(
                      isSelected
                          ? (selectedAssetPath ?? assetPath)
                          : assetPath,
                      width: isSelected ? 26 : 24,
                      height: isSelected ? 26 : 24,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    )
                  : Icon(
                      icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: isSelected ? 26 : 24,
                    ),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: isSelected ? 1 : 0.65,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
