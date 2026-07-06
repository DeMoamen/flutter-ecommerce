import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class WishlistProvider with ChangeNotifier {
  Map<String, Product> _items = {};
  Map<String, String> _wishlistIds = {};
  String? _loadedUserId;

  WishlistProvider() {
    Future.microtask(() => refresh());
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _loadedUserId = null;
      refresh();
    });
  }

  Map<String, Product> get items {
    return {..._items};
  }

  String? get _userId => SupabaseService.client.auth.currentUser?.id;

  Future<void> refresh() async {
    final userId = _userId;
    if (_loadedUserId == userId) return;
    _loadedUserId = userId;
    if (userId == null) {
      _items = {};
      _wishlistIds = {};
      notifyListeners();
      return;
    }
    try {
      final dbItems = await SupabaseService.getWishlistItems(userId);
      _items = {};
      _wishlistIds = {};
      for (final dbItem in dbItems) {
        final product = Product.fromJson(dbItem['products'] as Map<String, dynamic>);
        _items[product.id] = product;
        _wishlistIds[product.id] = dbItem['id'] as String;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  bool isFavorite(String productId) {
    return _items.containsKey(productId);
  }

  Future<void> toggleFavorite(Product product) async {
    final userId = _userId;
    if (_items.containsKey(product.id)) {
      final wishlistId = _wishlistIds[product.id];
      if (userId != null && wishlistId != null) {
        try {
          await SupabaseService.removeFromWishlist(wishlistId);
        } catch (e) {
          debugPrint('Error removing from wishlist: $e');
        }
      }
      _items.remove(product.id);
      _wishlistIds.remove(product.id);
    } else {
      String? wishlistId;
      if (userId != null) {
        try {
          await SupabaseService.addToWishlist(
            userId: userId,
            productId: product.id,
          );
          final dbItems = await SupabaseService.getWishlistItems(userId);
          final wishItem = dbItems.firstWhere(
            (item) => item['product_id'] == product.id,
            orElse: () => {},
          );
          if (wishItem.isNotEmpty) {
            wishlistId = wishItem['id'] as String;
          }
        } catch (e) {
          debugPrint('Error adding to wishlist in DB: $e');
        }
      }
      _items.putIfAbsent(product.id, () => product);
      if (wishlistId != null) {
        _wishlistIds[product.id] = wishlistId;
      }
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    _wishlistIds = {};
    notifyListeners();
  }
}
