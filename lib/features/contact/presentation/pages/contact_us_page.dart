import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/components/components.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  final List<Map<String, dynamic>> _teamMembers = const [
    {
      "name": "Abhishek Nyer",
      "role": "Fest Organiser",
      "image": null,
      "phone": "+91 91409 67688",
      "email": "abhishek.22104@knit.ac.in",
      "social": {"linkedin": "#", "instagram": "#"}
    },
    {
      "name": "Anshrit Singh",
      "role": "Fest Secretary",
      "image": null,
      "phone": "+91 80762 95221",
      "email": "anshrit.22319@knit.ac.in",
      "social": {"linkedin": "#", "instagram": "#"}
    },
    {
      "name": "Lucky Gautam",
      "role": "Outreach Executive",
      "phone": "+91 80762 95221",
    },
    {
      "name": "Ashish Sharma",
      "role": "Outreach Executive",
      "phone": "+91 63867 60936",
    },
    {
      "name": "Arsh Ansari",
      "role": "Outreach Executive",
      "phone": "+91 73111 40604",
    },
    {
      "name": "Atul Kataria",
      "role": "Outreach Executive",
      "phone": "+91 95573 17638",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: CustomScrollView(
          slivers: [
             SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  "Contact Us",
                   style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: true,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "OUR LEGION",
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "The dedicated corps behind Effulgence '26.\nUnited by code, driven by design.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    _buildTeamGrid(_teamMembers),

                    const SizedBox(height: AppSpacing.xxl),
                    // Join CTA
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.primary.withValues(alpha:0.5)),
                        ),
                        child: Text(
                          "Want to join the ranks? Contact specific coordinators.",
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                       const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGrid(List<Map<String, dynamic>> team) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate item width based on available space
        final double totalWidth = constraints.maxWidth;
        final int crossAxisCount = totalWidth > 600 ? 3 : 2;
        final double spacing = AppSpacing.md;
        final double itemWidth = (totalWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: team.map((member) {
            return SizedBox(
              width: itemWidth,
              child: _TeamMemberCard(member: member),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final Map<String, dynamic> member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Use min size to wrap content
        children: [
          // Image Section - Fixed Aspect Ratio
          AspectRatio(
            aspectRatio: 1.0, // Square image
            child: Container(
              color: AppColors.surface,
              child: member['image'] != null
                  ? Image.network(
                      member['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          // Details Section - Flexible Height
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surface.withValues(alpha: 0.8),
                  AppColors.surface,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Role
                  Text(
                    member['name'] ?? '',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2))),
                    child: Text(
                      member['role'] ?? '',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Contact Info
                  if (member['phone'] != null)
                    _ContactRow(
                      icon: Icons.phone_rounded,
                      text: member['phone'],
                      onTap: () async {
                        final uri = Uri.parse("tel:${member['phone']}");
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  if (member['email'] != null) ...[
                    // Add slight spacing if both phone and email exist
                    if (member['phone'] != null) const SizedBox(height: 4),
                    _ContactRow(
                      icon: Icons.email_rounded,
                      text: member['email'],
                      onTap: () async {
                        final uri = Uri.parse("mailto:${member['email']}");
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                  ],

                  // Social Icons
                  if (member['social'] != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 12, color: AppColors.divider),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (member['social']['instagram'] != null)
                          _SocialLink(
                            icon: FontAwesomeIcons.instagram,
                            url: member['social']['instagram'],
                          ),
                        if (member['social']['linkedin'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _SocialLink(
                              icon: FontAwesomeIcons.linkedinIn,
                              url: member['social']['linkedin'],
                            ),
                          ),
                        if (member['social']['github'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: _SocialLink(
                              icon: FontAwesomeIcons.github,
                              url: member['social']['github'],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bgSecondary,
            AppColors.bgPrimary,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          size: 40,
          color: AppColors.textMuted.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _SocialLink extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialLink({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: SelectableText(
                text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
