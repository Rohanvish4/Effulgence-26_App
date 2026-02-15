import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/components/components.dart';
import '../widgets/rohan_profile_card.dart';

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

                    const RohanUltimateCard(),

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
    return AnimatedGradientBorder(
      borderRadius: AppSpacing.radiusMd,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section with Tech Overlay
                AspectRatio(
                  aspectRatio: 0.9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      member['image'] != null
                          ? Image.network(member['image'], fit: BoxFit.cover)
                          : _buildPlaceholder(),
                      // Bottom Vignette
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.surface.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Area
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['name']?.toUpperCase() ?? '',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member['role']?.toUpperCase() ?? '',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (member['phone'] != null)
          _MiniIconButton(
            icon: Icons.phone_android_rounded,
            onTap: () => launchUrl(Uri.parse("tel:${member['phone']}")),
          ),
        if (member['email'] != null)
          _MiniIconButton(
            icon: Icons.alternate_email_rounded,
            onTap: () => launchUrl(Uri.parse("mailto:${member['email']}")),
          ),
        if (member['social']?['linkedin'] != null)
          _MiniIconButton(
            icon: FontAwesomeIcons.linkedinIn,
            onTap: () => launchUrl(Uri.parse(member['social']['linkedin'])),
          ),
      ],
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
class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;

  const AnimatedGradientBorder({
    super.key,
    required this.child,
    this.borderRadius = 12,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientPainter(
            rotation: _controller.value,
            radius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _GradientPainter extends CustomPainter {
  final double rotation;
  final double radius;

  _GradientPainter({required this.rotation, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Laser/Glow effect
    paint.shader = SweepGradient(
      colors: [
        Colors.transparent,
        AppColors.primary, // Teal
        AppColors.primary.withOpacity(0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.4, 1.0],
      transform: GradientRotation(rotation * 2 * 3.14159),
    ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GradientPainter oldDelegate) => true;
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


