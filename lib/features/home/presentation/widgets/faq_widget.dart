import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FaqWidget extends StatelessWidget {
  const FaqWidget({super.key});

  static const List<Map<String, String>> _faqData = [
    {
      "question": "What is Effulgence?",
      "answer":
          "Effulgence is the flagship national level techno management fest of KNIT Sultanpur. It brings together competitions, hackathons, workshops, expert talks, startup initiatives, and cultural showcases to create a complete innovation ecosystem.",
    },
    {
      "question": "Who can participate in Effulgence?",
      "answer":
          "The fest is open to students from KNIT as well as participants from colleges and universities across the country.",
    },
    {
      "question": "How can I register for Effulgence?",
      "answer":
          "Participants can register online through the official Effulgence platform or complete on campus registration at the help desk during the fest.",
    },
    {
      "question": "Is there any registration fee?",
      "answer":
          "Yes. A nominal fee of ₹1499 provides full access to the four day fest experience, including accommodation, meals, night passes, and eligibility to participate in all competitions, workshops, and activities.",
    },
    {
      "question": "What does the registration fee include?",
      "answer":
          "The registration package covers four day accommodation, food services, entry to DJ and Star Nights, cultural events, and access to all technical and management competitions and workshops.",
    },
    {
      "question": "Can I participate in multiple events?",
      "answer":
          "Yes. Participants may register for multiple events provided the schedules do not overlap.",
    },
    {
      "question": "Are there team events available?",
      "answer":
          "Yes. Effulgence features both individual and team based competitions. Team sizes vary by event and are specified in the respective rulebooks.",
    },
    {
      "question": "Will participants receive certificates?",
      "answer":
          "All registered participants receive official participation certificates. Winners and top performers are awarded merit certificates along with prizes.",
    },
    {
      "question": "Are workshops and tech talks included?",
      "answer":
          "Yes. The fest hosts industry led workshops, expert sessions, and technical talks across AI, Cyber Security, Robotics, DevOps, Blockchain, and emerging technologies.",
    },
    {
      "question": "What cultural activities are part of the fest?",
      "answer":
          "Beyond competitions, Effulgence features DJ Nights, Star Night performances, live music, and cultural showcases, creating a vibrant techno cultural experience for all attendees.",
    },
    {
      "question":
          "Are accommodation facilities available for outstation participants?",
      "answer":
          "Yes. On campus accommodation is provided for registered outstation participants as part of the registration package.",
    },
    {
      "question": "Will food be provided during the event?",
      "answer":
          "Yes. Meals are included in the registration package, with additional food stalls available across the campus for convenience.",
    },
    {
      "question": "What should I carry on the day of reporting?",
      "answer":
          "Participants should carry a valid college ID card, registration confirmation, and essential personal items for their stay.",
    },
    {
      "question": "What are the prize details for winners?",
      "answer":
          "Winners receive cash prizes, goodies, certificates, and recognition. Detailed prize structures are announced separately for each event.",
    },
    {
      "question": "Where can I find the event schedule and updates?",
      "answer":
          "The complete schedule, announcements, and updates are published on the official website, Mobile App and social media channels of Effulgence.",
    },
    {
      "question": "Whom should I contact for queries or support?",
      "answer":
          "For assistance, participants can reach the organizing committee through the official help desk, email, or social media channels.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: AppSpacing.lg),
        ..._faqData.map((item) => _buildFaqItem(item)),
      ],
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 1,
                width: 40,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'INQUIRIES',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                height: 1,
                width: 40,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'F.A.Q.s',
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            collapsedIconColor: AppColors.textSecondary,
            iconColor: AppColors.primary,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            title: Text(
              item['question']!,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Text(
                  item['answer']!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
