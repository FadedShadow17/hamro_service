import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.bookingId,
    super.userId,
    super.providerId,
    required super.read,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? json['body'] ?? '',
      bookingId: json['bookingId'],
      userId: json['userId'],
      providerId: json['providerId'],
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      message: message,
      bookingId: bookingId,
      userId: userId,
      providerId: providerId,
      read: read,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'bookingId': bookingId,
      'userId': userId,
      'providerId': providerId,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
