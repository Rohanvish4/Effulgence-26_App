import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/sponsor_entity.dart';
import '../cubit/sponsors_cubit.dart';
import '../cubit/sponsors_state.dart';
import '../widgets/sponsor_card.dart';

/// Sponsors list page showing all sponsors categorized by tier
class SponsorsListPage extends StatefulWidget {
  const SponsorsListPage({super.key});

  @override
  State<SponsorsListPage> createState() => _SponsorsListPageState();
}

class _SponsorsListPageState extends State<SponsorsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SponsorsCubit>().loadSponsors();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        floatingElements: EffulgenceBackgroundElements.dense,
        child: CustomScrollView(
          slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140.0,
            floating: true,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'SPONSORS',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'POWERED BY PARTNERS',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.bgPrimary.withValues(alpha: 0.9),
                      AppColors.bgPrimary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          BlocBuilder<SponsorsCubit, SponsorsState>(
            builder: (context, state) {
              if (state is SponsorsLoading) {
                return _buildLoadingState();
              }

              if (state is SponsorsError) {
                return _buildErrorState(state.message);
              }

              if (state is SponsorsLoaded) {
                return _buildLoadedState(state);
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
        ],
      ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerCard(
                width: double.infinity,
                height: 200,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Error Loading Sponsors', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                text: 'Retry',
                onPressed: () {
                  context.read<SponsorsCubit>().loadSponsors();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(SponsorsLoaded state) {
    final platinumSponsors = state.getSponsorsByTier(SponsorTier.platinum);
    final goldSponsors = state.getSponsorsByTier(SponsorTier.gold);
    final silverSponsors = state.getSponsorsByTier(SponsorTier.silver);
    final bronzeSponsors = state.getSponsorsByTier(SponsorTier.bronze);
    final isEmpty = platinumSponsors.isEmpty &&
        goldSponsors.isEmpty &&
        silverSponsors.isEmpty &&
        bronzeSponsors.isEmpty;

    if (isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: AppColors.primary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No Sponsors Available',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Currently, there are no sponsors to display. Please check back later.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Platinum Sponsors
        if (platinumSponsors.isNotEmpty) ...[
          _buildTierHeader('Platinum Sponsors', Icons.diamond),
          ...platinumSponsors.map(
            (sponsor) => SponsorCard(
              sponsor: sponsor,
              onTap: () => context.push('/sponsors/${sponsor.id}'),
            ),
          ),
        ],

        // Gold Sponsors
        if (goldSponsors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildTierHeader('Gold Sponsors', Icons.stars),
          ...goldSponsors.map(
            (sponsor) => SponsorCard(
              sponsor: sponsor,
              onTap: () => context.push('/sponsors/${sponsor.id}'),
            ),
          ),
        ],

        // Silver Sponsors
        if (silverSponsors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildTierHeader('Silver Sponsors', Icons.star),
          ...silverSponsors.map(
            (sponsor) => SponsorCard(
              sponsor: sponsor,
              onTap: () => context.push('/sponsors/${sponsor.id}'),
            ),
          ),
        ],

        // Bronze Sponsors
        if (bronzeSponsors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildTierHeader('Bronze Sponsors', Icons.star_half),
          ...bronzeSponsors.map(
            (sponsor) => SponsorCard(
              sponsor: sponsor,
              onTap: () => context.push('/sponsors/${sponsor.id}'),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildTierHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
