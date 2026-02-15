import 'package:flutter/material.dart';
import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/components/components.dart';

class AboutEffulgencePage extends StatelessWidget {
  const AboutEffulgencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.minimal,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                "About Effulgence",
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    /// Header
                    Text(
                      "Effulgence '26",
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "INNOVATION AND BEYOND",
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    /// Intro
                    const _SectionText(
                      text:
                          "Effulgence is the flagship National Level Techno-Management Fest of Kamla Nehru Institute of Technology, Sultanpur. Managed by the Council of Student Activities, it serves as a high impact convergence platform where technology, entrepreneurship, and leadership intersect to create measurable innovation outcomes.",
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    /// Legacy
                    const _SectionHeader(title: "A Legacy of Excellence"),
                    const _SectionText(
                      text:
                          "For years, Effulgence has defined the technical culture of KNIT. It is not merely an event but a launchpad where engineers, builders, and founders transform ideas into execution. The 2026 edition advances this legacy with stronger industry alignment and deeper technical rigor.",
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    /// Updated Powered by Innovation
                    const _SectionHeader(title: "Powered by Innovation"),
                    const _SectionText(
                      text:
                          "Effulgence is executed through a coalition of high performance student driven forums that collectively deliver robotics, software engineering, entrepreneurship, and core technical excellence:",
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    const _EventBullet(
                      title: "ROBOTICS CLUB",
                      description:
                          "Leads robotics, automation, embedded systems, aeromodelling, and hardware innovation initiatives. Drives practical engineering through competitions, prototyping, and real world problem solving.",
                    ),

                    const _EventBullet(
                      title: "PTSC (Programming & TechSkills Club)",
                      description:
                          "The campus nucleus for competitive programming, full stack development, hackathons, and algorithmic mastery. Builds industry ready software engineers through hands on coding culture.",
                    ),

                    const _EventBullet(
                      title:
                          "IISF (Innovation Incubation & Startup Foundation)",
                      description:
                          "The official startup and incubation ecosystem enabling founders to transform ideas into scalable ventures through mentorship, incubation support, and entrepreneurial exposure.",
                    ),

                    const _EventBullet(
                      title: "MEF (Mechanical Engineering Forum)",
                      description:
                          "Focused on mechanical design, manufacturing, simulation, and fabrication challenges. Promotes applied engineering through build centric competitions and technical projects.",
                    ),

                    const _EventBullet(
                      title: "IEI KNIT Chapter",
                      description:
                          "Professional engineering body that facilitates technical symposiums, paper presentations, and competency development aligned with national engineering standards.",
                    ),

                    const _EventBullet(
                      title: "FORONIX",
                      description:
                          "A multidisciplinary technology community emphasizing electronics, IoT, and experimental innovation. Encourages rapid prototyping and next generation hardware solutions.",
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// Event Verticals
                    const _SectionHeader(title: "The Battlefields"),
                    const _SectionText(
                      text:
                          "Participants compete across diverse domains, each designed to evaluate precision, creativity, and execution capability:",
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildFeatureCard(
                      icon: Icons.precision_manufacturing_rounded,
                      title: "Robotics",
                      description:
                          "Autonomous robotics, Robo-Wars, and intelligent machines engineered for high stakes competitive scenarios.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.code_rounded,
                      title: "Programming",
                      description:
                          "Competitive coding, hackathons, and full stack development challenges that benchmark algorithmic and system design expertise.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.business_center_rounded,
                      title: "Entrepreneurial",
                      description:
                          "Management and entrepreneurial simulations including business plans, strategy cases, and corporate decision making contests.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.architecture_rounded,
                      title: "Miscellaneous",
                      description:
                          "Mechanical and civil engineering design challenges focused on structures, systems, and build excellence.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.sports_esports_rounded,
                      title: "Esports",
                      description:
                          "Competitive gaming tournaments featuring popular titles, testing reflexes, strategy, and team coordination.",
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// Beyond Competition
                    const _SectionHeader(title: "Beyond Competition"),
                    const _SectionText(
                      text:
                          "Effulgence '26 extends beyond competitions into a high-energy experiential ecosystem designed to inspire, connect, and celebrate. The fest hosts industry-led Tech Talks, hands-on workshops, and masterclasses across AI, Cyber Security, DevOps, Robotics, and emerging technologies, enabling participants to gain practical insights from domain experts. As the sun sets, the campus transforms into a vibrant cultural arena featuring electrifying DJ Nights, Star Night performances, live music, and immersive cultural showcases. From innovation to celebration, every moment is curated to foster networking, creativity, and unforgettable memories, delivering a complete techno-cultural experience under one unified platform.",
                    ),  

                    const SizedBox(height: AppSpacing.xxl),

                    /// Footer
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.hub_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            "KNIT Sultanpur, Uttar Pradesh",
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 0,
                            ),
                          ),
                          // const SizedBox(height: 12),
                          // const _SectionText(
                          //   text: "KNIT Sultanpur, Uttar Pradesh",
                          // ),
                        ],
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha:0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha:0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
        height: 1.6,
      ),
    );
  }
}

class _EventBullet extends StatelessWidget {
  final String title;
  final String description;

  const _EventBullet({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
