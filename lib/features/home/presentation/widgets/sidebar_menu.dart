import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:url_launcher/url_launcher.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:effulgence26_mobile_app/features/auth/presentation/cubit/auth_state.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_spacing.dart';

import 'package:effulgence26_mobile_app/components/components.dart';

class SidebarMenu extends StatelessWidget {
  final VoidCallback onClose;

  const SidebarMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            top: 40,
            bottom: 40,
          ), // Increased top/bottom padding
          alignment: Alignment.centerLeft, // Align to left side
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [
                // User Profile Abstract
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    String userName = "Guest";
                    String email = "effulgence@knit.ac.in";
                    String? userImageUrl;

                    if (state is AuthAuthenticated) {
                      userName = state.user.name;
                      email = state.user.email;
                      userImageUrl = state.user.imageUrl;
                    }

                    return Container(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Don't stretch row
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.surface,
                            backgroundImage: userImageUrl?.isNotEmpty == true
                                ? CachedNetworkImageProvider(userImageUrl!)
                                : null,
                            child: userImageUrl?.isNotEmpty == true
                                ? null
                                : Icon(
                                    Icons.person_rounded,
                                    size: 25,
                                    color: AppColors.textMuted,
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                email,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Menu Items
                _MenuItem(
                  icon: Icons.home_rounded,
                  title: 'Home',
                  onTap: onClose,
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Effulgence',
                  onTap: () {
                    context.push('/about');
                    onClose();
                  },
                ),
                // _MenuItem(
                //   icon: Icons.people_outline_rounded,
                //   title: 'Our Team',
                //   onTap: () {
                //     // context.push('/team');
                //     onClose();
                //   },
                // ),
                // _MenuItem(
                //   icon: Icons.code_rounded,
                //   title: 'Developers',
                //   onTap: () {
                //     // context.push('/developers');
                //     onClose();
                //   },
                // ),
                // _MenuItem(
                //   icon: Icons.photo_library_outlined,
                //   title: 'Gallery',
                //   onTap: () {
                //     // context.push('/gallery');
                //     onClose();
                //   },
                // ),
                _MenuItem(
                  icon: Icons.contact_support_outlined,
                  title: 'Contact Us',
                  onTap: () {
                    context.push('/contact');
                    onClose();
                  },
                ),

                const Spacer(),

                // Social Links
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SocialIcon(
                      icon: FontAwesomeIcons.instagram,
                      url: 'https://instagram.com/effulgence_knit',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "Version 1.0.3",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Important for width
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
