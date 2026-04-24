import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

/// Demo implementation of [NotificationRepository].
/// Returns empty notifications list; mark-read operations silently succeed.
class NotificationDemoRepository implements NotificationRepository {
  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 10,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> markNotificationRead(
          String notificationId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> markAllNotificationsRead() async =>
      const Right(null);
}
