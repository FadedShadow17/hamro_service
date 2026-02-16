import '../../domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.userId,
    required super.subject,
    required super.message,
    required super.category,
    super.rating,
    required super.isApproved,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user']?['_id'] ?? '',
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      category: json['category'] ?? 'General',
      rating: json['rating'],
      isApproved: json['isApproved'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'message': message,
      'category': category,
      if (rating != null) 'rating': rating,
    };
  }

  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      userId: userId,
      subject: subject,
      message: message,
      category: category,
      rating: rating,
      isApproved: isApproved,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
