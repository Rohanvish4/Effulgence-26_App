


import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_assets.dart';
import '../../../../components/components.dart';
import '../../../../core/utils/url_utils.dart';


class Tilt3DWrapper extends StatefulWidget {
  final Widget child;
  const Tilt3DWrapper({super.key, required this.child});

  @override
  State<Tilt3DWrapper> createState() => _Tilt3DWrapperState();
}

class _Tilt3DWrapperState extends State<Tilt3DWrapper> {
  double xRotation = 0;
  double yRotation = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          // Calculate rotation based on touch position
          yRotation += details.delta.dx / 100;
          xRotation -= details.delta.dy / 100;
          // Clamp values to prevent excessive flipping
          xRotation = xRotation.clamp(-0.2, 0.2);
          yRotation = yRotation.clamp(-0.2, 0.2);
        });
      },
      onPanEnd: (_) => setState(() { xRotation = 0; yRotation = 0; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateX(xRotation)
          ..rotateY(yRotation),
        alignment: FractionalOffset.center,
        child: widget.child,
      ),
    );
  }
}

class RohanUltimateCard extends StatelessWidget {
  const RohanUltimateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Tilt3DWrapper(
      child: HeroGradientBorder(
        borderRadius: 24,
        child: Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. Holographic Scanlines
                _buildScanlines(),

                Column(
                  children: [
                    _buildTopHeader(),
                    const Spacer(),
                    _buildIdentitySection(),
                    const Spacer(),
                    _buildTacticalActionHub(),
                  ],
                ),
                
                // 2. Floating Specular Highlight
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 100,
                          spreadRadius: 20,
                        )
                      ]
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanlines() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => Container(
            height: 2,
            color: index % 2 == 0 ? Colors.white : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildChip("ARCHITECT_ID: 001", AppColors.primary),
          _buildChip("CORE_X_ENCRYPTED", AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Avatar with "Energy Ring"
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: AppColors.primary,
              child: CircleAvatar(
                radius: 44,
                backgroundImage: UrlUtils.isValidUrl("https://media.licdn.com/dms/image/v2/D5603AQFpqtKhkTK-0Q/profile-displayphoto-shrink_200_200/B56ZT8Sp2YHEAc-/0/1739399537807?e=2147483647&v=beta&t=Jk-qCM4cs1XB3RfKuXVr9IrWQ-B0tJUF3fYePM68EVY")
                    ? const NetworkImage("https://media.licdn.com/dms/image/v2/D5603AQFpqtKhkTK-0Q/profile-displayphoto-shrink_200_200/B56ZT8Sp2YHEAc-/0/1739399537807?e=2147483647&v=beta&t=Jk-qCM4cs1XB3RfKuXVr9IrWQ-B0tJUF3fYePM68EVY")
                    : null,
              ),
            ),
            // Floating Micro-badges around avatar
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 16),
              ),
            )
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ROHAN V.", style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900, letterSpacing: 4)),
            Text("ENGINEERING THE FUTURE", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 8)),
            const SizedBox(height: 8),
            _buildMiniTag("FLUTTER_EXPERT"),
          ],
        )
      ],
    );
  }

  Widget _buildTacticalActionHub() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MiniIconButton(icon: Icons.phone_android_rounded, onTap: () {}),
          _MiniIconButton(icon: FontAwesomeIcons.github, onTap: () {}),
          _MiniIconButton(icon: FontAwesomeIcons.linkedinIn, onTap: () {}),
          _MiniIconButton(icon: Icons.alternate_email_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 7, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMiniTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MiniIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primary.withValues(alpha: 0.2),
        highlightColor: AppColors.primary.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// class RohanProfileCard extends StatelessWidget {
//   const RohanProfileCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return HeroGradientBorder(
//       borderRadius: 16,
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: AppColors.bgSecondary.withValues(alpha: 0.9),
//           borderRadius: BorderRadius.circular(16),
//           // Fallback pattern since tech_grid.png might not exist
//           image: DecorationImage(
//            image: const AssetImage(AppAssets.logoPng), // Using logo as subtle background
//             opacity: 0.05,
//             fit: BoxFit.contain, // Changed to contain to avoid stretched logo
//             alignment: Alignment.centerRight,
//           ),
//         ),
//         child: Column(
//           children: [
//             // Header with Admin Badge
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _buildBadge("SYSTEM_ARCHITECT", AppColors.primary),
//                   _buildBadge("LEAD_DEV", AppColors.secondary),
//                 ],
//               ),
//             ),
            
//             // Your Photo/Avatar
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: AppColors.primary,
//               child: CircleAvatar(
//                 radius: 48,
//                 backgroundImage: NetworkImage("https://media.licdn.com/dms/image/v2/D5603AQFpqtKhkTK-0Q/profile-displayphoto-shrink_200_200/B56ZT8Sp2YHEAc-/0/1739399537807?e=2147483647&v=beta&t=Jk-qCM4cs1XB3RfKuXVr9IrWQ-B0tJUF3fYePM68EVY"), // Need a real URL or asset here
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Name & Bio
//             Text(
//               "ROHAN VISHWAKARMA",
//               style: AppTextStyles.titleLarge.copyWith(
//                 fontWeight: FontWeight.w900,
//                 letterSpacing: 2,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               "Full Stack Developer | Flutter Specialist",
//               style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
//             ),
            
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               child: Divider(color: AppColors.border, thickness: 0.5),
//             ),

//             // Action Hub
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _MiniIconButton(
//                     icon: Icons.phone_android_rounded,
//                     onTap: () => _launch("tel:+919569379055"),
//                   ),
//                   _MiniIconButton(
//                     icon: FontAwesomeIcons.github,
//                     onTap: () => _launch("https://github.com/rohanvish4"),
//                   ),
//                   _MiniIconButton(
//                     icon: FontAwesomeIcons.linkedinIn,
//                     onTap: () => _launch("https://linkedin.com/in/rohanvish4"),
//                   ),
//                   _MiniIconButton(
//                     icon: Icons.language_rounded,
//                     onTap: () => _launch("https://rohanv.dev"), // Your portfolio
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBadge(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         border: Border.all(color: color.withValues(alpha: 0.3)),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         label,
//         style: AppTextStyles.labelSmall.copyWith(
//           color: color,
//           fontSize: 8,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   void _launch(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) await launchUrl(uri);
//   }
// }

// HeroGradientBorder moved to components/ui/hero_gradient_border.dart

