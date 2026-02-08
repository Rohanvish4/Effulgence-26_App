import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/pages/admin_events_page.dart';
import 'package:effulgence26_mobile_app/features/event/presentation/pages/events_list_page.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/pages/user_profile_page.dart';
import 'package:effulgence26_mobile_app/features/sponsors/presentation/pages/sponsors_list_page.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  void closeDrawer() {
    HapticFeedback.vibrate();
     if (_animationController.isCompleted) {
      _animationController.reverse();
      setState(() => _isDrawerOpen = false);
    }
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
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex >= pages.length ? 0 : _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: _buildFloatingNavBar(isAdmin),
        );
      },
    );
  }

  Widget _buildFloatingNavBar(bool isAdmin) {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25), // Floating margin
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
      onTap: () => {
        HapticFeedback.lightImpact(),
        setState(() => _currentIndex = index)
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
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
          if (isSelected)
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            )
          else
            const SizedBox(height: 12), // Maintain height to prevent shift
        ],
      ),
    );
  }
}
