import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_assets.dart';
import 'components/common/particle_background.dart';

/// Effulgence'26 Splash Screen - Emerald Titanium Edition
/// The entry point for the "Innovation and Beyond" experience.
class EffulgenceSplashScreen extends StatefulWidget {
  const EffulgenceSplashScreen({super.key});

  @override
  State<EffulgenceSplashScreen> createState() => _EffulgenceSplashScreenState();
}

class _EffulgenceSplashScreenState extends State<EffulgenceSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: ParticleBackground(
        child: Center(
          child: RepaintBoundary(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with Scale and Fade Transition
                // FadeTransition(
                //   opacity: _fadeAnimation,
                //   child: ScaleTransition(
                //     scale: _scaleAnimation,
                //     child:
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppColors.primaryGlow(opacity: 0.1, blur: 40),
                  ),
                  child: Image.asset(
                    AppAssets.logoPng,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                // ),
                // ),

                const SizedBox(height: 48),

                // Title and Tagline
                // FadeTransition(
                //   opacity: _fadeAnimation,
                //   child: 
                  Column(
                    children: [
                      Image.asset(
                        AppAssets.textLight,
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'INNOVATION AND BEYOND',
                        style: AppTextStyles.labelSmall.copyWith(
                          letterSpacing: 6,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                // ),

                const SizedBox(height: 80),

                // System Initialization UI
                _buildLoadingStatus(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingStatus() {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
            children: [
              // Linear indicator feels more "Technical/Industrial" than circular
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'INITIALIZING_CORE_SYSTEMS...',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 1.5,
                  fontSize: 9,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace', // If available, use for a terminal feel
                ),
              ),
            ],
        
      ),
    );
  }
}