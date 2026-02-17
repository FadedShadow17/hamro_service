import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider<NotificationRepositoryImpl>((ref) {
  throw UnimplementedError('notificationRepositoryProvider must be overridden');
});

final notificationsProvider = FutureProvider<List<NotificationEntity>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getNotifications();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (notifications) => notifications,
  );
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final result = await repository.getUnreadCount();
  return result.fold(
    (failure) => 0,
    (count) => count,
  );
});
