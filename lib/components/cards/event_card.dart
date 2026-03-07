import 'package:cached_network_image/cached_network_image.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/core/utils/url_utils.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String domain;
  final String? imageUrl;
  final String venue;
  final DateTime dateTime;
  final String status;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool showRegisterButton;
  final bool isRegistered;
  final bool isRegistering;
  final String? eventType; // 'INDIVIDUAL' or 'TEAM'
  final VoidCallback? onRegister;
  final String? heroTag;

  const EventCard({
    super.key,
    required this.title,
    required this.domain,
    this.imageUrl,
    required this.venue,
    required this.dateTime,
    required this.status,
    this.onTap,
    this.accentColor,
    this.showRegisterButton = false,
    this.isRegistered = false,
    this.isRegistering = false,
    this.eventType,
    this.onRegister,
    this.heroTag,
  });

  Color get _accentColor => accentColor ?? _getDomainColor(domain);

  Color _getDomainColor(String domain) {
    switch (domain.toLowerCase()) {
      case 'coding':
      case 'software':
        return AppColors.electricBlue;
      case 'robotics':
      case 'hardware':
        return AppColors.crimsonRed;
      case 'core':
      case 'engineering':
        return AppColors.royalPurple;
      case 'workshop':
        return AppColors.innovationGreen;
      default:
        return AppColors.cyanTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardElevation(),
        ),
        child: SizedBox(
          width: double.infinity,
          child: IntrinsicHeight(
            // Use IntrinsicHeight to match strip height to content
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children vertically
              children: [
                // LEFT ACCENT STRIP
                Container(
                  width: AppSpacing.accentStripThick,
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppSpacing.radiusLg),
                      bottomLeft: Radius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                ),

                // CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImage(),

                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            _buildInfoRow(Icons.location_on_outlined, venue),
                            const SizedBox(height: AppSpacing.xs),
                            _buildInfoRow(
                              Icons.schedule,
                              'TBA',
                            ),

                            if (showRegisterButton) ...[
                              const SizedBox(height: AppSpacing.sm),
                              _buildRegisterButton(),
                            ],
                          ],
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
    );
  }

  Widget _buildImage() {
    final height = AppSpacing.cardImageHeight;

    Widget imageWidget;
    final validUrl = UrlUtils.isValidUrl(imageUrl) ? imageUrl : null;

    if (validUrl != null) {
      imageWidget = CachedNetworkImage(
        imageUrl: validUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _imageFallback(height),
        placeholder: (_, __) => _imageFallback(height),
      );
    } else {
      imageWidget = _imageFallback(height);
    }

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _imageFallback(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.surface,
      child: Icon(
        Icons.event,
        size: 48,
        color: _accentColor.withValues(alpha: 0.4),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: _accentColor),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    // If already registered, show registered state
    if (isRegistered) {
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 16),
              const SizedBox(width: AppSpacing.xs),
              const Text('REGISTERED'),
            ],
          ),
        ),
      );
    }

    // Get button text based on event type
    final buttonText = eventType == 'TEAM' ? 'CREATE TEAM' : 'REGISTER';

    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: isRegistering ? null : onRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.black,
        ),
        child: isRegistering
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(buttonText),
      ),
    );
  }

}
