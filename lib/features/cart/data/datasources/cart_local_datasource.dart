import '../../domain/entities/cart_item.dart';

abstract class CartLocalDataSource {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(CartItem item);
  Future<void> removeFromCart(String itemId);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  // In-memory storage for session-only cart
  final List<CartItem> _cartItems = [];

  @override
  Future<List<CartItem>> getCartItems() async {
    return List.from(_cartItems);
  }

  @override
  Future<void> addToCart(CartItem item) async {
    _cartItems.add(item);
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    _cartItems.removeWhere((item) => item.id == itemId);
  }

  @override
  Future<void> clearCart() async {
    _cartItems.clear();
  }
}
