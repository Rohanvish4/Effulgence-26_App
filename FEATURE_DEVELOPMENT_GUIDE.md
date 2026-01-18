# How to Add a New Feature to Effulgence'26 Mobile App

This guide explains how to add new features to the project following the **existing architecture pattern**. Our architecture is a **simplified Clean Architecture** without Equatable or UseCases for simplicity.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Step-by-Step Feature Implementation](#step-by-step-feature-implementation)
3. [Real-World Example: Adding "Notifications" Feature](#real-world-example-adding-notifications-feature)
4. [Key Principles to Follow](#key-principles-to-follow)
5. [Common Patterns](#common-patterns)
6. [Troubleshooting](#troubleshooting)

---

## Architecture Overview

Our architecture has **3 layers**:

```
lib/features/[feature_name]/
├── data/                      # Data Layer
│   ├── datasources/          # API calls & local storage
│   ├── models/               # JSON serialization models
│   └── repositories/         # Repository implementations
├── domain/                    # Domain Layer
│   ├── entities/             # Business objects (pure Dart classes)
│   ├── repositories/         # Repository interfaces (contracts)
│   └── [params/]             # Optional: Request parameters
└── presentation/              # Presentation Layer
    ├── cubit/                # State management (Cubit + States)
    ├── pages/                # Full screen pages
    └── widgets/              # Reusable widgets
```

### **Data Flow**: 
```
UI → Cubit → Repository Interface → Repository Implementation → DataSource → API
                     ↓
                  Response
                     ↓
              State Emission
                     ↓
                UI Updates
```

### **What We DON'T Use**:
- **Equatable** - States are simple const classes
- **UseCases** - Cubits call repositories directly
- **GetIt/Injectable** - We use Provider for dependency injection
- **Freezed** - We use simple models with manual JSON serialization

---

## Step-by-Step Feature Implementation

### **Step 1: Create Feature Folder Structure**

Create the following folder structure in `lib/features/`:

```bash
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   └── [feature]_remote_datasource.dart
│   ├── models/
│   │   └── [entity]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [entity]_entity.dart
│   └── repositories/
│       └── [feature]_repository.dart
└── presentation/
    ├── cubit/
    │   ├── [feature]_cubit.dart
    │   └── [feature]_state.dart
    ├── pages/
    │   └── [feature]_page.dart
    └── widgets/
        └── [custom_widget].dart
```

---

### **Step 2: Define Domain Entities**

**Location**: `lib/features/[feature]/domain/entities/`

**Purpose**: Pure Dart classes representing business objects

**Example** (`notification_entity.dart`):
```dart
/// Notification entity for domain layer
class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final String type; // 'EVENT', 'GENERAL', 'ALERT'
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  // Computed properties (optional)
  bool get isUnread => !isRead;
  String get formattedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}
```

**Key Points**:
- Use `const` constructors
- All fields are `final`
- No JSON serialization here (that's in models)
- Add computed properties for UI convenience
- No Equatable needed

---

### **Step 3: Create Data Models**

**Location**: `lib/features/[feature]/data/models/`

**Purpose**: Handle JSON serialization/deserialization

**Example** (`notification_model.dart`):
```dart
import '../../domain/entities/notification_entity.dart';

/// Notification model for data layer
/// Extends entity to inherit all properties
/// Adds JSON serialization capabilities
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
  });

  /// Create model from JSON (from API response)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'GENERAL',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// Convert model to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

**Key Points**:
- Model **extends** Entity
- Include `fromJson` factory constructor
- Include `toJson` method
- Handle null safety with `??` operators
- Use `super` parameters for cleaner code

---

### **Step 4: Define Repository Interface**

**Location**: `lib/features/[feature]/domain/repositories/`

**Purpose**: Define contract for data operations (what, not how)

**Example** (`notifications_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

/// Notifications repository interface (contract)
/// Defines WHAT operations are available, not HOW they work
/// Repository implementations in data layer will implement this interface
abstract class NotificationsRepository {
  /// Get all notifications for current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);
}
```

**Key Points**:
- Use `abstract class` (interface)
- Return `Future<Either<Failure, T>>` for error handling
- Use domain entities, not models
- No implementation here, just method signatures

---

### **Step 5: Create Remote DataSource**

**Location**: `lib/features/[feature]/data/datasources/`

**Purpose**: Handle all API calls

**Example** (`notifications_remote_datasource.dart`):
```dart
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

/// Abstract interface for notifications remote data source
abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
}

/// Implementation of notifications remote data source
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get(ApiConstants.notifications);

      if (response.statusCode == 200) {
        final List data = response.data['notifications'] ?? [];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }

      throw ServerException(
        message: 'Failed to load notifications',
        statusCode: response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await apiClient.patch(
        '${ApiConstants.notifications}/$notificationId/read',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to mark notification as read',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiClient.patch('${ApiConstants.notifications}/read-all');

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to mark all notifications as read',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await apiClient.delete(
        '${ApiConstants.notifications}/$notificationId',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to delete notification',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
```

**Key Points**:
- Create abstract interface + implementation
- Use `ApiClient` for API calls
- Throw `ServerException` on errors
- Return **Models**, not Entities
- Handle `DioException` properly

---

### **Step 6: Implement Repository**

**Location**: `lib/features/[feature]/data/repositories/`

**Purpose**: Implement repository interface, handle errors, convert models to entities

**Example** (`notifications_repository_impl.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

/// Notifications repository implementation
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    // Check network connectivity
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      // Call remote data source (returns models)
      final notifications = await remoteDataSource.getNotifications();
      
      // Models extend entities, so we can return them directly
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
```

**Key Points**:
- Always check `networkInfo.isConnected` first
- Try-catch all data source calls
- Convert exceptions to failures
- Return `Either<Failure, T>`
- Models extend entities, so we can return models as entities

---

### **Step 7: Create State Classes**

**Location**: `lib/features/[feature]/presentation/cubit/`

**Purpose**: Define all possible UI states

**Example** (`notifications_state.dart`):
```dart
/// Base state for notifications
abstract class NotificationsState {
  const NotificationsState();
}

/// Initial state
class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Loading state
class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Loaded state with data
class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;

  const NotificationsLoaded({required this.notifications});
}

/// Error state
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});
}

/// Mark as read success
class NotificationMarkedAsRead extends NotificationsState {
  const NotificationMarkedAsRead();
}

/// Delete success
class NotificationDeleted extends NotificationsState {
  const NotificationDeleted();
}
```

**Key Points**:
- Use `const` constructors
- Create specific states for each operation
- Include data in success states
- Include error messages in error states
- No Equatable needed

---

### **Step 8: Create Cubit**

**Location**: `lib/features/[feature]/presentation/cubit/`

**Purpose**: Manage state and business logic

**Example** (`notifications_cubit.dart`):
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

/// Notifications Cubit for managing notification state
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;

  NotificationsCubit({required this.repository}) 
      : super(const NotificationsInitial());

  /// Load notifications
  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());

    final result = await repository.getNotifications();

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) => emit(NotificationsLoaded(notifications: notifications)),
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await repository.markAsRead(notificationId);

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) {
        emit(const NotificationMarkedAsRead());
        // Reload to refresh UI
        loadNotifications();
      },
    );
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) => loadNotifications(),
    );
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final result = await repository.deleteNotification(notificationId);

    result.fold(
      (failure) => emit(NotificationsError(message: failure.message)),
      (_) {
        emit(const NotificationDeleted());
        loadNotifications();
      },
    );
  }
}
```

**Key Points**:
- Emit states using `emit()`
- Use `result.fold()` for Either handling
- Reload data after mutations
- Call repository methods directly (no UseCases)

---

### **Step 9: Register in Dependency Injection**

**Location**: `lib/core/providers/app_providers.dart`

**Add your feature to the providers**:

```dart
// Import your feature
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

// Inside getProviders() method:

// NOTIFICATIONS FEATURE DEPENDENCY INJECTION
final notificationsRemoteDataSource = NotificationsRemoteDataSourceImpl(
  apiClient: apiClient,
);

final notificationsRepository = NotificationsRepositoryImpl(
  remoteDataSource: notificationsRemoteDataSource,
  networkInfo: networkInfo,
);

final notificationsCubit = NotificationsCubit(
  repository: notificationsRepository,
);

// Add to return list:
return [
  // ... existing providers ...
  BlocProvider<NotificationsCubit>.value(value: notificationsCubit),
];
```

---

### **Step 10: Create UI (Page)**

**Location**: `lib/features/[feature]/presentation/pages/`

**Example** (`notifications_page.dart`):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Load notifications on page open
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsState>(
        builder: (context, state) {
          // Loading state
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationsCubit>().loadNotifications();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Loaded state
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(
                child: Text('No notifications'),
              );
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return ListTile(
                  leading: Icon(
                    notification.isRead 
                      ? Icons.notifications 
                      : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Colors.blue,
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead 
                        ? FontWeight.normal 
                        : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(notification.message),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<NotificationsCubit>()
                          .deleteNotification(notification.id);
                    },
                  ),
                  onTap: () {
                    if (!notification.isRead) {
                      context
                          .read<NotificationsCubit>()
                          .markAsRead(notification.id);
                    }
                  },
                );
              },
            );
          }

          // Initial state
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

### **Step 11: Add API Constants**

**Location**: `lib/core/constants/api_constants.dart`

```dart
class ApiConstants {
  // ... existing constants ...
  
  // Notifications Endpoints
  static const String notifications = '/notifications';
}
```

---

### **Step 12: Add Route (if needed)**

**Location**: `lib/router.dart`

```dart
GoRoute(
  path: '/notifications',
  name: 'notifications',
  builder: (context, state) => const NotificationsPage(),
),
```

---

## Key Principles to Follow

### **DO:**
1. **Follow the 3-layer architecture** (Data, Domain, Presentation)
2. **Use Either<Failure, T>** for error handling
3. **Check network connectivity** before API calls
4. **Emit states** for UI updates
5. **Use const constructors** wherever possible
6. **Add comments** explaining the flow
7. **Handle null values** with `??` operators
8. **Return models from DataSource**, entities from Repository

### **DON'T:**
1. Don't use Equatable on states
2. Don't create UseCases (call repository directly from Cubit)
3. Don't use GetIt (use Provider/BlocProvider)
4. Don't put business logic in UI
5. Don't forget to register in `app_providers.dart`
6. Don't skip error handling

---

## Common Patterns

### **Pattern 1: Network Error Handling Template**

```dart
@override
Future<Either<Failure, T>> methodName() async {
  if (!await networkInfo.isConnected) {
    return const Left(NetworkFailure());
  }

  try {
    final result = await remoteDataSource.methodName();
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } catch (e) {
    return Left(UnknownFailure(message: e.toString()));
  }
}
```

### **Pattern 2: Cubit Method Template**

```dart
Future<void> performAction() async {
  emit(const LoadingState());

  final result = await repository.performAction();

  result.fold(
    (failure) => emit(ErrorState(message: failure.message)),
    (data) => emit(SuccessState(data: data)),
  );
}
```

### **Pattern 3: BlocBuilder UI Template**

```dart
BlocBuilder<YourCubit, YourState>(
  builder: (context, state) {
    if (state is LoadingState) {
      return const CircularProgressIndicator();
    }
    
    if (state is ErrorState) {
      return Text('Error: ${state.message}');
    }
    
    if (state is SuccessState) {
      return YourWidget(data: state.data);
    }
    
    return const SizedBox.shrink();
  },
)
```

---

## Troubleshooting

### **Issue: Cubit not found in widget tree**
**Solution**: Make sure you added `BlocProvider<YourCubit>` in `app_providers.dart`

### **Issue: Network error even when connected**
**Solution**: Check `NetworkInfo` implementation and permissions

### **Issue: JSON parsing error**
**Solution**: Check your model's `fromJson` matches API response structure

### **Issue: State not updating**
**Solution**: Make sure you're calling `emit()` in your Cubit

---

## Reference Examples in Codebase

Study these existing features to understand the pattern:

1. **Auth Feature** (`lib/features/auth/`)
   - OTP authentication
   - Token management
   - User registration

2. **Event Feature** (`lib/features/event/`)
   - List/detail views
   - Registration flow

---

## Checklist for New Feature

- [ ] Created feature folder structure
- [ ] Defined domain entities
- [ ] Created data models with JSON serialization
- [ ] Defined repository interface
- [ ] Implemented remote data source
- [ ] Implemented repository
- [ ] Created state classes
- [ ] Created cubit
- [ ] Registered in `app_providers.dart`
- [ ] Added API constants
- [ ] Created UI pages/widgets
- [ ] Added routes (if needed)
- [ ] Tested all states (loading, success, error)
- [ ] Ran `flutter analyze` (0 issues)

---

**Now you're ready to add any feature following this architecture!**

For questions, review existing features in the codebase or refer to this guide.
