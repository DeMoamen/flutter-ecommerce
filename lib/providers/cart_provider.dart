import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  String? _loadedUserId;

  CartProvider() {
    Future.microtask(() => refresh());
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _loadedUserId = null;
      refresh();
    });
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  String? get _userId => SupabaseService.client.auth.currentUser?.id;

  Future<void> refresh() async {
    final userId = _userId;
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    if (userId == null) {
      _items = {};
      notifyListeners();
      return;
    }
    try {
      final dbItems = await SupabaseService.getCartItems(userId);
      _items = {};
      for (final dbItem in dbItems) {
        final cartItem = CartItem.fromJson(dbItem);
        _items[cartItem.id] = cartItem;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> addItem(Product product) async {
    final userId = _userId;
    if (_items.containsKey(product.id)) {
      final existingItem = _items[product.id]!;
      final newQuantity = existingItem.quantity + 1;
      if (userId != null && existingItem.cartItemId != null) {
        await SupabaseService.updateCartItemQuantity(
          cartItemId: existingItem.cartItemId!,
          quantity: newQuantity,
        );
      }
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          cartItemId: existingCartItem.cartItemId,
          product: existingCartItem.product,
          quantity: newQuantity,
        ),
      );
    } else {
      String? cartItemId;
      if (userId != null) {
        try {
          await SupabaseService.addToCart(
            userId: userId,
            productId: product.id,
            quantity: 1,
          );
          final dbItems = await SupabaseService.getCartItems(userId);
          final freshItem = dbItems.firstWhere(
            (item) => item['product_id'] == product.id,
            orElse: () => {},
          );
          if (freshItem.isNotEmpty) {
            final freshCartItem = CartItem.fromJson(freshItem);
            cartItemId = freshCartItem.cartItemId;
          }
        } catch (e) {
          debugPrint('Error adding to cart in DB: $e');
        }
      }
      _items.putIfAbsent(
        product.id,
        () => CartItem(
          id: DateTime.now().toString(),
          cartItemId: cartItemId,
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    final item = _items[productId];
    final userId = _userId;
    if (item != null && userId != null && item.cartItemId != null) {
      await SupabaseService.removeFromCart(item.cartItemId!);
    }
    _items.remove(productId);
    notifyListeners();
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    final userId = _userId;
    if (item.quantity > 1) {
      final newQuantity = item.quantity - 1;
      if (userId != null && item.cartItemId != null) {
        await SupabaseService.updateCartItemQuantity(
          cartItemId: item.cartItemId!,
          quantity: newQuantity,
        );
      }
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          cartItemId: existingCartItem.cartItemId,
          product: existingCartItem.product,
          quantity: newQuantity,
        ),
      );
    } else {
      if (userId != null && item.cartItemId != null) {
        await SupabaseService.removeFromCart(item.cartItemId!);
      }
      _items.remove(productId);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    final userId = _userId;
    if (userId != null) {
      await SupabaseService.clearCart(userId);
    }
    _items = {};
    notifyListeners();
  }
}
