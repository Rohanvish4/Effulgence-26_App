import 'package:effulgence26_mobile_app/core/providers/app_providers.dart';
import 'package:effulgence26_mobile_app/router.dart';
import 'package:effulgence26_mobile_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: EffulgenceSplashScreen());
        }

        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: const Color(0xFF0F172A),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFEF4444),
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ERROR INITIALIZING',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final providers = snapshot.data as List<SingleChildWidget>;
        return MultiProvider(
          providers: providers,
          child: Builder(
            builder: (context) {
              final authCubit = context.read<AuthCubit>();
              final appRouter = AppRouter(authCubit: authCubit);
              return MaterialApp.router(
                title: 'Effulgence 26',
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                  ),
                  useMaterial3: true,
                ),
                routerConfig: appRouter.router,
              );
            },
          ),
        );
      },
    );
  }

  Future<List<SingleChildWidget>> _initializeApp() async {
    // Start both the providers initialization and the splash delay simultaneously
    final providersFuture = AppProviders.getProviders();
    final splashDelay = Future.delayed(const Duration(seconds: 1));

    // Wait for both to complete
    await Future.wait([providersFuture, splashDelay]);

    // Return the providers
    return providersFuture;
  }
}
