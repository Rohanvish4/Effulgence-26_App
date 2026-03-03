import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../components/loading/loading_indicators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/referral_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class MyReferralsPage extends StatefulWidget {
  const MyReferralsPage({super.key});

  @override
  State<MyReferralsPage> createState() => _MyReferralsPageState();
}

class _MyReferralsPageState extends State<MyReferralsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadReferrals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'MY REFERRALS',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileReferralsLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is ProfileReferralsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () =>
                        context.read<ProfileCubit>().loadReferrals(),
                    child: Text(
                      'Retry',
                      style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileReferralsLoaded) {
            final referrals = state.referrals;

            if (referrals.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ProfileCubit>().loadReferrals(),
              color: AppColors.primary,
              backgroundColor: AppColors.bgSecondary,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _buildHeader(referrals.length),
                  const SizedBox(height: AppSpacing.md),
                  ...referrals
                      .map((r) => _buildReferralTile(r))
                      .toList(),
                ],
              ),
            );
          }

          return const Center(child: AppLoadingIndicator());
        },
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.group_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'Person' : 'People'} Referred',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'These users joined using your referral code',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralTile(ReferralEntity referral) {
    final initials = referral.name.isNotEmpty
        ? referral.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    final isInternal = referral.isInternalUser;
    final joinDate = referral.createdAt != null
        ? '${referral.createdAt!.day}/${referral.createdAt!.month}/${referral.createdAt!.year}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInternal
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: Text(
            initials,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                referral.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isInternal) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  'KNIT',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              referral.collegeName ?? referral.email,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (referral.registrationId != null) ...[
              const SizedBox(height: 2),
              Text(
                'ID: ${referral.registrationId}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ],
        ),
        trailing: joinDate != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Joined',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    joinDate,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Referrals Yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Share your registration ID with friends and they\'ll appear here once they register.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
