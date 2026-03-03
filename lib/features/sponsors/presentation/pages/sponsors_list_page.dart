import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../components/components.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';

import '../cubit/sponsors_cubit.dart';
import '../cubit/sponsors_state.dart';
import '../widgets/sponsor_card.dart';

/// Sponsors list page showing all sponsors
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
        child: RefreshIndicator(
          onRefresh: () async => context.read<SponsorsCubit>().loadSponsors(),
          color: AppColors.primary,
          backgroundColor: AppColors.bgSecondary,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
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
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: AppSpacing.lg, bottom: 16),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomLeft,
          child: Column(
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
                height: 260,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorState(
        title: 'Error Loading Sponsors',
        message: message,
        onRetry: () => context.read<SponsorsCubit>().loadSponsors(),
      ),
    );
  }

  Widget _buildLoadedState(SponsorsLoaded state) {
    if (state.sponsors.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.handshake_outlined,
          title: 'No Sponsors Yet',
          message: 'Check back soon — exciting partners are on the way!',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final sponsor = state.sponsors[index];
          return SponsorCard(
            sponsor: sponsor,
            index: index,
            onTap: () => context.push('/sponsors/${sponsor.id}'),
          );
        },
        childCount: state.sponsors.length,
      ),
    );
  }
}
