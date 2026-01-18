import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════════
// APP AVATAR (with Border & Initials)
// ═══════════════════════════════════════════════════════════════
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.backgroundColor,
  });

  String get _initials {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: backgroundColor ?? AppColors.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primary).withValues(
              alpha: 0.3,
            ),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          _initials,
          style: AppTextStyles.titleMedium.copyWith(
            color: backgroundColor ?? AppColors.primary,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP LOGO (Effulgence Branding)
// ═══════════════════════════════════════════════════════════════
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 64, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: AppColors.accentGlow(
              AppColors.primary,
              opacity: 0.5,
              blur: 16,
            ),
          ),
          child: Center(
            child: Text(
              'E',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.black,
                fontSize: size * 0.55,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(height: AppSpacing.sm),
          // "EFFULGENCE'26"
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              "EFFULGENCE'26",
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          // Tagline
          Text(
            'INNOVATION AND BEYOND',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GRADIENT TEXT (Animated Brush Stroke Effect)
// ═══════════════════════════════════════════════════════════════
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText({
    super.key,
    required this.text,
    this.style,
    this.gradient = AppColors.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text.toUpperCase(),
        style: (style ?? AppTextStyles.displayMedium).copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STATUS BADGE (Live, Upcoming, Completed)
// ═══════════════════════════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({super.key, required this.status, this.color});

  Color get _color {
    if (color != null) return color!;
    switch (status.toUpperCase()) {
      case 'LIVE':
      case 'APPROVED':
        return AppColors.success;
      case 'UPCOMING':
      case 'PENDING':
        return AppColors.warning;
      case 'COMPLETED':
        return AppColors.textMuted;
      case 'REJECTED':
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: _color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.toUpperCase() == 'LIVE')
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: _color, blurRadius: 4, spreadRadius: 1),
                ],
              ),
            ),
          Text(
            status.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: _color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DIVIDER WITH TEXT (Section Separator)
// ═══════════════════════════════════════════════════════════════
class DividerWithText extends StatelessWidget {
  final String text;
  final Color? color;

  const DividerWithText({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppColors.divider;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, dividerColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            text.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [dividerColor, Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// // /// Divider with text
// // class DividerWithText extends StatelessWidget {
// //   final String text;

// //   const DividerWithText({super.key, required this.text});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         const Expanded(child: Divider(color: AppColors.divider)),
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
// //           child: Text(
// //             text,
// //             style: AppTextStyles.bodySmall.copyWith(
// //               color: AppColors.textTertiary,
// //             ),
// //           ),
// //         ),
// //         const Expanded(child: Divider(color: AppColors.divider)),
// //       ],
// //     );
// //   }
// // }

// // ═══════════════════════════════════════════════════════════════
// // DIVIDER WITH TEXT (Section Separator)
// // ═══════════════════════════════════════════════════════════════
// class DividerWithText extends StatelessWidget {
//   final String text;
//   final Color? color;

//   const DividerWithText({
//     super. key,
//     required this.text,
//     this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dividerColor = color ?? AppColors. divider;

//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             height: 1,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.transparent, dividerColor],
//                 begin: Alignment.centerLeft,
//                 end: Alignment. centerRight,
//               ),
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
//           child: Text(
//             text.toUpperCase(),
//             style: AppTextStyles.labelSmall.copyWith(
//               color: AppColors.textMuted,
//               letterSpacing: 1,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             height: 1,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [dividerColor, Colors.transparent],
//                 begin: Alignment.centerLeft,
//                 end: Alignment. centerRight,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
