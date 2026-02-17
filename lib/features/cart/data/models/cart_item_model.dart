import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.serviceId,
    required super.serviceName,
    required super.servicePrice,
    required super.serviceOptionId,
    required super.serviceOptionName,
    required super.serviceOptionPrice,
    required super.serviceOptionDuration,
    required super.selectedDate,
    required super.selectedTimeSlot,
    required super.address,
    required super.area,
    super.notes,
    required super.totalPrice,
  });

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      id: entity.id,
      serviceId: entity.serviceId,
      serviceName: entity.serviceName,
      servicePrice: entity.servicePrice,
      serviceOptionId: entity.serviceOptionId,
      serviceOptionName: entity.serviceOptionName,
      serviceOptionPrice: entity.serviceOptionPrice,
      serviceOptionDuration: entity.serviceOptionDuration,
      selectedDate: entity.selectedDate,
      selectedTimeSlot: entity.selectedTimeSlot,
      address: entity.address,
      area: entity.area,
      notes: entity.notes,
      totalPrice: entity.totalPrice,
    );
  }
}
