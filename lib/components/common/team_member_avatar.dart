import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TeamMemberAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final Color? backgroundColor;

  const TeamMemberAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.bgPrimary, width: 2),
      ),
      child: ClipOval(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildInitials(),
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
