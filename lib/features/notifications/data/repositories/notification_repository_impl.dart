import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity/connectivity_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final notifications = await remoteDataSource.getNotifications();
      return Right(notifications.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(String notificationId) async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      final notification = await remoteDataSource.markAsRead(notificationId);
      return Right(notification.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Right(0);
    }

    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return const Right(0);
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    final hasInternet = await connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      return const Left(CacheFailure('No internet connection'));
    }

    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
