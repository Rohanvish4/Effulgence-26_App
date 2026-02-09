import 'package:effulgence26_mobile_app/core/theme/app_colors.dart';
import 'package:effulgence26_mobile_app/core/theme/app_spacing.dart';
import 'package:effulgence26_mobile_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class FaqWidget extends StatelessWidget {
  const FaqWidget({super.key});

  static const List<Map<String, String>> _faqData = [
  {
    "question": "What is Effulgence and who can participate?",
    "answer": "Effulgence is the flagship national-level techno-management fest of KNIT Sultanpur, featuring competitions, hackathons, workshops, expert talks, startup initiatives, and cultural events. It is open to students from KNIT as well as colleges and universities across the country."
  },
  {
    "question": "How can I register and is there a registration fee?",
    "answer": "Participants can register online through the official Effulgence platform or on campus at the help desk during the fest. The registration fee is ₹1499."
  },
  {
    "question": "What does the registration fee include?",
    "answer": "The fee covers four-day accommodation and meals, entry to DJ and Star Nights, cultural events, and eligibility to participate in all technical, management competitions, workshops, and activities."
  },
  {
    "question": "Can I participate in multiple or team events?",
    "answer": "Yes. Participants can take part in multiple events as long as schedules do not overlap. Both individual and team-based events are available, with team size details mentioned in respective rulebooks."
  },
  {
    "question": "Where can I find schedules, updates, and contact support?",
    "answer": "The full event schedule, announcements, and updates are available on the official Effulgence website and social media channels. For queries, participants can contact the organizing committee via the official help desk, email, or social platforms."
  }
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
