import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/supabase_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  String? _loadedUserId;
  bool _isLoading = false;

  OrderProvider() {
    Future.microtask(() => refresh());
    SupabaseService.client.auth.onAuthStateChange.listen((data) {
      _loadedUserId = null;
      refresh();
    });
  }

  List<Order> get orders {
    return [..._orders];
  }

  bool get isLoading => _isLoading;

  String? get _userId => SupabaseService.client.auth.currentUser?.id;

  Future<void> refresh({bool force = false}) async {
    final userId = _userId;
    if (!force && _loadedUserId == userId) return;
    _loadedUserId = userId;
    if (userId == null) {
      _orders = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final dbOrders = await SupabaseService.getUserOrders(userId);
      _orders = [];
      for (final dbOrder in dbOrders) {
        final orderItemsData = dbOrder['order_items'] as List<dynamic>? ?? [];
        final cartItems = <CartItem>[];
        for (final itemData in orderItemsData) {
          if (itemData['products'] == null) continue;
          final productMap = Map<String, dynamic>.from(itemData['products'] as Map);
          final product = Product.fromJson(productMap);
          cartItems.add(CartItem(
            id: itemData['id'] as String? ?? DateTime.now().toString(),
            product: product,
            quantity: (itemData['quantity'] as num?)?.toInt() ?? 1,
          ));
        }
        final order = Order.fromJson(dbOrder, cartItems);
        _orders.add(order);
      }
    } catch (e, stacktrace) {
      debugPrint('=======================================');
      debugPrint('🔴 Error loading orders in OrderProvider:');
      debugPrint('$e');
      debugPrint('Stacktrace: $stacktrace');
      debugPrint('=======================================');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final userId = _userId;
    if (userId == null) {
      _orders.insert(
        0,
        Order(
          id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now(),
        ),
      );
      notifyListeners();
      return;
    }

    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      final items = cartProducts.map((item) => {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      }).toList();

      await SupabaseService.createOrder(
        userId: userId,
        orderId: orderId,
        totalAmount: total,
        items: items,
      );

      await refresh(force: true);
    } catch (e) {
      debugPrint('Error creating order: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final userId = _userId;
    if (userId != null) {
      await SupabaseService.cancelOrder(orderId);
    }
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = Order(
        id: _orders[index].id,
        amount: _orders[index].amount,
        products: _orders[index].products,
        dateTime: _orders[index].dateTime,
        status: 'Cancelled',
      );
      notifyListeners();
    }
  }
}
