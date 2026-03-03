import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import '../services/analytics_service.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/notification_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/event/data/datasources/events_remote_datasource.dart';
import '../../features/event/data/repositories/events_repository_impl.dart';
import '../../features/event/presentation/cubit/events_cubit.dart';

import '../../features/profile/data/datasources/user_profile_remote_datasource.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';

import '../../features/sponsors/data/datasources/sponsor_local_datasource.dart';
import '../../features/sponsors/data/repositories/sponsor_repository_impl.dart';
import '../../features/sponsors/presentation/cubit/sponsors_cubit.dart';

import '../../features/qrcode/data/datasources/qrcode_remote_datasource.dart';
import '../../features/qrcode/data/repositories/qrcode_repository_impl.dart';
import '../../features/qrcode/presentation/cubit/qrcode_cubit.dart';
import '../../features/qrcode/presentation/cubit/qr_verification_cubit.dart';

import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/presentation/cubit/notification_cubit.dart';

import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/cubit/admin_cubit.dart';

/// App-wide providers and dependency injection
class AppProviders {
  static Future<List<SingleChildWidget>> getProviders() async {
    // =========================================================================
    // EXTERNAL DEPENDENCIES (Shared across features)
    // =========================================================================
    
    // Parallelize independent async intializatins 
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      getApplicationDocumentsDirectory(),
    ]);

    final sharedPreferences = results[0] as SharedPreferences;
    final appDocDir = results[1] as io.Directory; 
    
    const flutterSecureStorage = FlutterSecureStorage();

    // Initialize persistent cookie jar for session persistence across app restarts
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );

    // Core network utilities
    final networkInfo = NetworkInfoImpl();
    final apiClient = ApiClient(
      // secureStorage: flutterSecureStorage,
      cookieJar: cookieJar,
    );

    // =========================================================================
    // NOTIFICATION SERVICE - Initialize early for AuthCubit dependency
    // =========================================================================
    final notificationService = NotificationService(apiClient: apiClient);
    // Initialize notification service in the background to avoid blocking app startup
    notificationService.initialize().then((_) {
      debugPrint('Notification service initialized');
    }).catchError((e) {
      debugPrint('Failed to initialize Notification Service: $e');
    });

    // =========================================================================
    // NOTIFICATION FEATURE DEPENDENCY INJECTION
    // =========================================================================
    final notificationRepository = NotificationRepositoryImpl(
      apiClient: apiClient,
      networkInfo: networkInfo,
    );
    final notificationCubit = NotificationCubit(repository: notificationRepository);

    // =========================================================================
    // AUTH FEATURE DEPENDENCY INJECTION
    // =========================================================================

    // DATA LAYER: Data Sources (API calls & local storage)
    final authLocalDataSource = AuthLocalDataSourceImpl(
      sharedPreferences: sharedPreferences,
      secureStorage: flutterSecureStorage,
    );

    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);

    // DATA LAYER: Repository Implementation (coordinates data sources)
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      networkInfo: networkInfo,
    );

    // PRESENTATION LAYER: Cubit (state management)
    final authCubit = AuthCubit(
      authRepositoryImpl: authRepository,
      notificationService: notificationService,
    );

    // Allow notification deep-links to wait until auth is ready.
    notificationService.bindAuthCubit(authCubit);

    // Initialize auth state on app startup
    await authCubit.checkAuthStatus();

    // Listen for session expiration events (401/403) from ApiClient
    // and trigger logout when they occur
    apiClient.sessionExpiredStream.listen((_) {
      authCubit.logout();
    });

    // =========================================================================
    // EVENTS FEATURE DEPENDENCY INJECTION
    // =========================================================================

    // DATA LAYER: Remote Data Source (API calls for events)
    final eventsRemoteDataSource = EventsRemoteDataSourceImpl(
      apiClient: apiClient,
      authLocalDataSource: authLocalDataSource,
    );

    // DATA LAYER: Repository Implementation (coordinates data sources)
    final eventsRepository = EventsRepositoryImpl(
      remoteDataSource: eventsRemoteDataSource,
      networkInfo: networkInfo,
    );

    // PRESENTATION LAYER: Cubit (state management for events)
    final eventsCubit = EventsCubit(eventsRepository);

    // =========================================================================
    // PROFILE FEATURE DEPENDENCY INJECTION
    // =========================================================================

    // DATA LAYER: Remote Data Source
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // DATA LAYER: Repository Implementation
    final profileRepository = UserProfileRepositoryImpl(
      remoteDataSource: profileRemoteDataSource,
      networkInfo: networkInfo,
    );

    // PRESENTATION LAYER: Cubit

    // =========================================================================
    // SPONSORS FEATURE DEPENDENCY INJECTION
    // =========================================================================

    // DATA LAYER: Local Data Source (mock data)
    final sponsorLocalDataSource = SponsorLocalDataSource();

    // DATA LAYER: Repository Implementation
    final sponsorRepository = SponsorRepositoryImpl(
      localDataSource: sponsorLocalDataSource,
    );

    // PRESENTATION LAYER: Cubit
    final sponsorsCubit = SponsorsCubit(repository: sponsorRepository);

    // =========================================================================
    // QR CODE FEATURE DEPENDENCY INJECTION
    // =========================================================================

    // DATA LAYER: Remote Data Source
    final qrCodeRemoteDataSource = QrCodeRemoteDataSourceImpl(
      apiClient: apiClient,
    );

    // DATA LAYER: Repository Implementation
    final qrCodeRepository = QrCodeRepositoryImpl(
      remoteDataSource: qrCodeRemoteDataSource,
      networkInfo: networkInfo,
    );

    // PRESENTATION LAYER: Cubit
    final qrCodeCubit = QrCodeCubit(repository: qrCodeRepository);
    final qrVerificationCubit = QrVerificationCubit(
      repository: qrCodeRepository,
    );

    // FlutterError.onError and PlatformDispatcher.instance.onError are
    // already configured in main.dart before runApp() for full coverage.


    // =========================================================================
    // ADMIN FEATURE DEPENDENCY INJECTION
    // =========================================================================

    final adminRemoteDataSource = AdminRemoteDataSourceImpl(apiClient: apiClient);
    final adminRepository = AdminRepositoryImpl(
      remoteDataSource: adminRemoteDataSource,
      networkInfo: networkInfo,
    );
    final adminCubit = AdminCubit(repository: adminRepository);

    // =========================================================================
    // PROVIDER REGISTRATION (Dependency Injection Container)
    // =========================================================================

    return [
      // =========================================================================
      // REPOSITORIES (Domain Layer Interfaces - Business Logics)
      // =========================================================================
      Provider<AuthRepositoryImpl>.value(value: authRepository),
      Provider<PersistCookieJar>.value(value: cookieJar),
      // Provider<EventsRepositoryImpl>.value(value: eventsRepository),
      Provider<UserProfileRepositoryImpl>.value(value: profileRepository),
      Provider<NotificationService>.value(value: notificationService),
      Provider<NotificationRepositoryImpl>.value(value: notificationRepository),
      Provider<ApiClient>.value(value: apiClient),
      Provider<AnalyticsService>.value(value: AnalyticsService.instance),

      // =========================================================================
      // CUBITS (Presentation Layer - State Management)
      // =========================================================================
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<EventsCubit>.value(value: eventsCubit),
      BlocProvider<ProfileCubit>.value(
        value: ProfileCubit(profileRepository: profileRepository),
      ),
      BlocProvider<SponsorsCubit>.value(value: sponsorsCubit),
      BlocProvider<QrCodeCubit>.value(value: qrCodeCubit),
      BlocProvider<QrVerificationCubit>.value(value: qrVerificationCubit),
      BlocProvider<NotificationCubit>.value(value: notificationCubit),
      // =========================================================================
      // FUTURE FEATURES: Add more providers here as needed
      // =========================================================================
      
      Provider<AdminRepository>.value(value: adminRepository),
      BlocProvider<AdminCubit>.value(value: adminCubit),
    ];
  }
}
