import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 10,
  });
  Future<Either<Failure, void>> markNotificationRead(String notificationId);
  Future<Either<Failure, void>> markAllNotificationsRead();
}
