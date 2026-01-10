import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource datasource;

  CartRepositoryImpl({required this.datasource});

  @override
  Future<List<CartItem>> getCartItems() {
    return datasource.getCartItems();
  }

  @override
  Future<void> addToCart(CartItem item) {
    return datasource.addToCart(item);
  }

  @override
  Future<void> removeFromCart(String itemId) {
    return datasource.removeFromCart(itemId);
  }

  @override
  Future<void> clearCart() {
    return datasource.clearCart();
  }
}
