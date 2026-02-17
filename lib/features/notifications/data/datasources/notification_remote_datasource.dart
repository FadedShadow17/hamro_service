import 'package:dio/dio.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> markAsRead(String notificationId);
  Future<int> getUnreadCount();
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/api/notifications');
      final data = response.data;

      List<dynamic> notificationsList = [];
      
      if (data is Map) {
        if (data.containsKey('notifications')) {
          notificationsList = data['notifications'] as List? ?? [];
        } else if (data.containsKey('data')) {
          final dataList = data['data'];
          if (dataList is List) {
            notificationsList = dataList;
          }
        }
      } else if (data is List) {
        notificationsList = data;
      }

      return notificationsList
          .map((notification) => NotificationModel.fromJson(
              Map<String, dynamic>.from(notification as Map)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to fetch notifications';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  @override
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final response = await _dio.patch('/api/notifications/$notificationId/read');
      final data = response.data;

      final notificationData = data is Map && data.containsKey('notification')
          ? data['notification']
          : data;

      return NotificationModel.fromJson(notificationData);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to mark notification as read';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread-count');
      final data = response.data;

      if (data is Map) {
        return data['count'] ?? data['unreadCount'] ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/api/notifications/mark-all-read');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          e.message ??
          'Failed to mark all as read';
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to mark all as read: ${e.toString()}');
    }
  }
}
