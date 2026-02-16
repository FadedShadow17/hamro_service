import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id;
  final String userId;
  final String subject;
  final String message;
  final String category;
  final int? rating;
  final bool isApproved;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContactEntity({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.category,
    this.rating,
    required this.isApproved,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        subject,
        message,
        category,
        rating,
        isApproved,
        createdAt,
        updatedAt,
      ];
}
