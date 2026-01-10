import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/repositories/cart_repository_impl.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final datasource = CartLocalDataSourceImpl();
  return CartRepositoryImpl(datasource: datasource);
});

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

class CartNotifier extends Notifier<CartState> {
  late final CartRepository repository;

  @override
  CartState build() {
    repository = ref.watch(cartRepositoryProvider);
    _loadCartItems();
    return CartState();
  }

  Future<void> _loadCartItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await repository.getCartItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addToCart(CartItem item) async {
    try {
      await repository.addToCart(item);
      await _loadCartItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      await repository.removeFromCart(itemId);
      await _loadCartItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await repository.clearCart();
      await _loadCartItems();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
