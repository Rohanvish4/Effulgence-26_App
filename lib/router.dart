import 'package:effulgence26_mobile_app/features/event/presentation/pages/events_list_page.dart';
import 'package:effulgence26_mobile_app/features/home/presentation/widgets/home_tab.dart';
import 'package:effulgence26_mobile_app/features/profile/presentation/pages/user_profile_edit_page.dart';
import 'package:effulgence26_mobile_app/features/admin/presentation/pages/admin_web_page.dart';
import 'package:effulgence26_mobile_app/features/contact/presentation/pages/contact_us_page.dart';
import 'package:effulgence26_mobile_app/features/about/presentation/pages/about_effulgence_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/event/presentation/pages/event_details_page.dart';
import 'features/event/presentation/pages/my_events_page.dart';
import 'features/sponsors/presentation/pages/sponsors_list_page.dart';
import 'features/sponsors/presentation/pages/sponsor_booth_page.dart';
import 'features/sponsors/presentation/cubit/sponsors_cubit.dart';
import 'features/sponsors/presentation/cubit/sponsors_state.dart';
import 'features/qrcode/presentation/pages/qrcode_page.dart';
import 'features/qrcode/presentation/pages/qr_scanner_page.dart';
import 'package:effulgence26_mobile_app/features/notifications/presentation/pages/notification_screen.dart';
import 'package:effulgence26_mobile_app/features/admin/presentation/pages/admin_broadcast_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App router configuration using GoRouter
/// GoRouter handles navigation and automatically redirects based on authentication state
class AppRouter {
  final AuthCubit authCubit;

  AppRouter({required this.authCubit});

  /// The main GoRouter instance
  /// - refreshListenable: Listens to auth state changes and triggers redirects
  /// - redirect: Logic to redirect users based on authentication status
  /// - routes: All available routes in the app
  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Shows navigation logs in debug mode
    // This listens to authCubit.stream and notifies GoRouter when auth state changes
    // When auth state changes (login/logout), GoRouter will re-evaluate redirects
    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    // Redirect logic: Called whenever navigation happens or auth state changes
    redirect: (context, state) {
      final authState = authCubit.state;

      // Debug logging
      debugPrint(' Router redirect - Current route: ${state.matchedLocation}');
      debugPrint(' Auth state: ${authState.runtimeType}');

      // Check if current route is an auth route (login/register)
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Check if user is authenticated (has valid user data)
      // We check for both AuthAuthenticated (after login) and AuthRegistrationSuccess (after registration)
      // because registration success should also allow access to the app
      final isAuthenticated = authState is AuthAuthenticated;
      final isRegistrationSuccess = authState is AuthRegistrationSuccess;

      // Check if auth is still loading (checking login status)
      final isLoading = authState is AuthLoading;

      debugPrint(
        ' isAuthRoute: $isAuthRoute, isAuthenticated: $isAuthenticated, isRegistrationSuccess: $isRegistrationSuccess, isLoading: $isLoading',
      );

      // If auth is still loading, don't redirect yet
      if (isLoading) {
        debugPrint(' Auth loading, staying on current route');
        return null; // Stay on current route while loading
      }

      // If user is NOT authenticated and NOT registration success and NOT on auth route, redirect to login
      // Fixed: Previously only checked !isAuthenticated, but AuthRegistrationSuccess should also grant access
      // This prevents redirecting to login after successful registration
      if (!isAuthenticated && !isRegistrationSuccess && !isAuthRoute) {
        debugPrint(' Not authenticated, redirecting to /login');
        return '/login';
      }

      // If user IS authenticated and ON auth route, redirect to home
      if (isAuthenticated && isAuthRoute) {
        debugPrint('Authenticated on auth route, redirecting to /');
        return '/';
      }

      // If registration was successful and ON auth route, redirect to home
      if (isRegistrationSuccess && isAuthRoute) {
        debugPrint('Registration success on auth route, redirecting to /');
        return '/';
      }

      debugPrint(' No redirect needed');
      // No redirect needed, stay on current route
      return null;
    },

    routes: [
      // Authentication Routes - Accessible when NOT logged in
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/editUserDetails",
        name: "editUserDetails",
        builder: (context, state) => const UserProfileEditPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Main App Routes - Require authentication
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Hometab(),
      ),

      // Admin Routes - Require admin/super_admin role
      // GoRoute(
      //   path: '/admin/events',
      //   name: 'adminEvents',
      //   builder: (context, state) {
      //     // Role check will be done in the page itself using AuthCubit
      //     return const AdminEventsPage();
      //   },
      // ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminWebPage(),
      ),
      GoRoute(
        path: '/events',
        name: 'events',
        builder: (context, state) => const EventsListPage(),
      ),

      GoRoute(
        path: '/events/:id',
        name: 'eventDetails',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailsPage(eventId: eventId);
        },
      ),

      // My Events Page - Shows user's registered events
      GoRoute(
        path: '/my-events',
        name: 'myEvents',
        builder: (context, state) => const MyEventsPage(),
      ),

      // Sponsors Routes
      GoRoute(
        path: '/sponsors',
        name: 'sponsors',
        builder: (context, state) => const SponsorsListPage(),
      ),

      GoRoute(
        path: '/sponsors/:id',
        name: 'sponsorBooth',
        builder: (context, state) {
          final sponsorId = state.pathParameters['id']!;

          // Get sponsor from cubit state
          return BlocBuilder<SponsorsCubit, SponsorsState>(
            builder: (context, sponsorState) {
              if (sponsorState is SponsorsLoaded) {
                final sponsor = sponsorState.sponsors.firstWhere(
                  (s) => s.id == sponsorId,
                  orElse: () => throw Exception('Sponsor not found'),
                );
                return SponsorBoothPage(sponsor: sponsor);
              }
              // If sponsors not loaded yet, show loading
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      ),

      // QR Code Route
      GoRoute(
        path: '/qrcode',
        name: 'qrcode',
        builder: (context, state) => const QrCodePage(),
      ),

      // QR Scanner Route (Admin)
      GoRoute(
        path: '/qr-scanner',
        name: 'qrScanner',
        builder: (context, state) => const QrScannerPage(),
      ),

      // Notifications Route
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // Contact Us Route
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactUsPage(),
      ),

      // Admin Broadcast Route
      GoRoute(
        path: '/admin/broadcast',
        name: 'adminBroadcast',
        builder: (context, state) => const AdminBroadcastPage(),
      ),

      // About Effulgence Route
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutEffulgencePage(),
      ),

      // Future x Routes
    ],

    // Error page for invalid routes
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${state.uri.path}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// GoRouter Refresh Stream Listener
/// This class listens to the AuthCubit's stream and notifies GoRouter
/// whenever the authentication state changes, triggering a redirect check
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    // Listen to the authCubit stream (BlocBase.stream)
    // Whenever auth state changes (login, logout, loading, etc.), notify listeners
    notifyListeners(); // Initial notification
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners(); // Notify GoRouter that auth state changed
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
