class BookingModel {
  final String id;
  final String userId;
  final String? providerId;
  final String serviceId;
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? provider;
  final String date;
  final String timeSlot;
  final String area;
  final String status;
  final String? paymentStatus;
  final DateTime? paidAt;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.userId,
    this.providerId,
    required this.serviceId,
    this.service,
    this.user,
    this.provider,
    required this.date,
    required this.timeSlot,
    required this.area,
    required this.status,
    this.paymentStatus,
    this.paidAt,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'],
      serviceId: json['serviceId'] ?? '',
      service: json['service'] is Map ? Map<String, dynamic>.from(json['service']) : null,
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      provider: json['provider'] is Map ? Map<String, dynamic>.from(json['provider']) : null,
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      area: json['area'] ?? '',
      status: (json['status'] ?? 'PENDING').toString().toUpperCase().trim(),
      paymentStatus: json['paymentStatus'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      paymentMethod: json['paymentMethod'],
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
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'service': service,
      'user': user,
      'provider': provider,
      'date': date,
      'timeSlot': timeSlot,
      'area': area,
      'status': status,
      'paymentStatus': paymentStatus,
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
