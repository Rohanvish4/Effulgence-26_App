import 'package:effulgence26_mobile_app/core/providers/app_providers.dart';
import 'package:effulgence26_mobile_app/router.dart';
import 'package:effulgence26_mobile_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/services/remote_config_service.dart';
import 'features/update/presentation/pages/update_required_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<SingleChildWidget>> _providersFuture;
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  @override
  void initState() {
    super.initState();
    // Pre-cache local data here if necessary before providers load
    _providersFuture = _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SingleChildWidget>>(
      future: _providersFuture,
      builder: (context, snapshot) {
        // 1. Connectivity-Aware Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: EffulgenceSplashScreen(),
          );
        }

        // 2. Handle Errors (including Forced Update)
        if (snapshot.hasError) {
          if (snapshot.error is UpdateRequiredException) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.darkTheme,
              home: UpdateRequiredPage(remoteConfigService: _remoteConfigService),
            );
          }
          return _buildGlobalErrorBuilder(snapshot.error.toString());
        }

        final providers = snapshot.data ?? [];

        return MultiProvider(
          providers: [
            ...providers,
            Provider<RemoteConfigService>.value(value: _remoteConfigService),
          ],
          child: const _AppContent(),
        );
      },
    );
  }

  Future<List<SingleChildWidget>> _initializeApp() async {
    try {
      // Initialize Remote Config Service early
      await _remoteConfigService.initialize();

      // Check for forced update
      if (await _remoteConfigService.isUpdateRequired()) {
        throw UpdateRequiredException();
      }

      // Parallel execution for speed
      final results = await Future.wait([
        AppProviders.getProviders(),
      ]);

      return results[0];
    } catch (e) {
      if (e is UpdateRequiredException) {
        rethrow; // Pass update exception through
      }
      // Log error to Sentry/Firebase here
      rethrow;
    }
  }

  Widget _buildGlobalErrorBuilder(String error) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.textMuted,
                  size: 48,
                ),
                const SizedBox(height: 24),
                Text(
                  'CONNECTION STRETCHED',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'re having trouble reaching the server. Check your internet  connection.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _providersFuture = _initializeApp();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    'RETRY INITIALIZATION',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateRequiredException implements Exception {}

class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  // Use a singleton-like pattern or late init for the router to survive re-builds
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Initialize router with the existing AuthCubit
    _appRouter = AppRouter(authCubit: context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Effulgence 26',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Production Optimization, Ensure the router handles deep links and redirects
      routerConfig: _appRouter.router,
      // Global builder for handling 2G Image loading issues
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
          ),
          child: child!,
        );
      },
    );
  }
}
