import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sponsor_entity.dart';
import '../widgets/sponsor_tier_badge.dart';

/// Individual sponsor booth page with immersive experience
class SponsorBoothPage extends StatelessWidget {
  final SponsorEntity sponsor;

  const SponsorBoothPage({super.key, required this.sponsor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Logo
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  // Logo
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'sponsor_logo_${sponsor.id}',
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CachedNetworkImage(
                              imageUrl: sponsor.logoUrl,
                              height: 100,
                              fit: BoxFit.contain,
                              errorWidget: (context, url, error) => Icon(
                                Icons.business,
                                size: 100,
                                color: AppColors.textSecondary,
                              ),
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SponsorTierBadge(tier: sponsor.tier, size: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Company Name and Tagline
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    sponsor.name,
                    style: AppTextStyles.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (sponsor.tagline != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      sponsor.tagline!,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'About',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      sponsor.description,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Image Gallery
          if (sponsor.imageGallery.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Icon(Icons.photo_library, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Gallery',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: sponsor.imageGallery.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: sponsor.imageGallery[index],
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surface,
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          color: AppColors.surface,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          // Products/Services
          if (sponsor.products.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Icon(Icons.category, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Products & Services',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            sponsor.products[index],
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: sponsor.products.length),
              ),
            ),
          ],

          // Social Links
          if (sponsor.socialLinks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Icon(Icons.share, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Connect With Us',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: sponsor.socialLinks.entries.map((entry) {
                    return _buildSocialButton(context, entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ),
          ],

          // Contact Information
          if (sponsor.contactEmail != null || sponsor.contactPhone != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.contact_mail, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Contact Information',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (sponsor.contactEmail != null) ...[
                        _buildContactRow(
                          Icons.email,
                          'Email',
                          sponsor.contactEmail!,
                          () => _launchUrl('mailto:${sponsor.contactEmail}'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (sponsor.contactPhone != null) ...[
                        _buildContactRow(
                          Icons.phone,
                          'Phone',
                          sponsor.contactPhone!,
                          () => _launchUrl('tel:${sponsor.contactPhone}'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Website Button
          if (sponsor.websiteUrl != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GradientButton(
                  text: 'Visit Website',
                  icon: Icons.language,
                  onPressed: () => _launchUrl(sponsor.websiteUrl!),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, String platform, String url) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'facebook':
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'twitter':
        icon = Icons.flutter_dash; // Using placeholder
        color = const Color(0xFF1DA1F2);
        break;
      case 'linkedin':
        icon = Icons.work;
        color = const Color(0xFF0A66C2);
        break;
      case 'instagram':
        icon = Icons.camera_alt;
        color = const Color(0xFFE4405F);
        break;
      case 'github':
        icon = Icons.code;
        color = const Color(0xFF181717);
        break;
      default:
        icon = Icons.link;
        color = AppColors.primary;
    }

    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              platform.toUpperCase(),
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
