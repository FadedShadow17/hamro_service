import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? bookingId;
  final String? userId;
  final String? providerId;
  final bool read;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.bookingId,
    this.userId,
    this.providerId,
    required this.read,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        bookingId,
        userId,
        providerId,
        read,
        createdAt,
      ];
}
