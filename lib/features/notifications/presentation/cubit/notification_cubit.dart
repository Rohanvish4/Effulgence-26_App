import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit({required this.repository}) : super(NotificationInitial());

  List<NotificationEntity> _currentNotifications = [];

  Future<void> getNotifications({int page = 1, int limit = 20}) async {
    emit(NotificationLoading());
    final result = await repository.getNotifications(page: page, limit: limit);
    result.fold(
      (failure) => emit(NotificationError(failure.message)),
      (notifications) {
        _currentNotifications = notifications;
        emit(NotificationLoaded(notifications));
      },
    );
  }

  Future<void> markNotificationRead(String notificationId) async {
    // 1. Optimistic Update
    final index = _currentNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updatedList = List<NotificationEntity>.from(_currentNotifications);
      updatedList[index] = updatedList[index].copyWith(isRead: true);
      
      _currentNotifications = updatedList; // Update local cache
      emit(NotificationLoaded(updatedList)); // Emit new state immediately

      // 2. Call API
      final result = await repository.markNotificationRead(notificationId);
      
      // 3. Handle Failure (Revert)
      result.fold(
        (failure) {
          // Revert change
          final originalList = List<NotificationEntity>.from(_currentNotifications);
          originalList[index] = originalList[index].copyWith(isRead: false);
          _currentNotifications = originalList;
          emit(NotificationError(failure.message));
          // Optionally re-emit loaded state after error so UI isn't stuck in error
          emit(NotificationLoaded(originalList)); 
        },
        (_) {
          // Success: No action needed as state is already updated
        },
      );
    }
  }

  Future<void> markAllNotificationsRead() async {
    // 1. Optimistic Update
    final updatedList = _currentNotifications.map((n) => n.copyWith(isRead: true)).toList();
    final originalList = _currentNotifications; // Keep backup
    
    _currentNotifications = updatedList;
    emit(NotificationLoaded(updatedList));

    // 2. Call API
    final result = await repository.markAllNotificationsRead();

    // 3. Handle Failure (Revert)
    result.fold(
      (failure) {
        _currentNotifications = originalList;
        emit(NotificationError(failure.message));
        emit(NotificationLoaded(originalList));
      },
      (_) {
        // Success
      },
    );
  }
}

