import 'product.dart';

class CartItem {
  final String id;
  final String? cartItemId;
  final Product product;
  int quantity;

  CartItem({
    required this.id,
    this.cartItemId,
    required this.product,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['product_id'] as String? ?? '',
      cartItemId: json['id'] as String?,
      product: json['products'] != null 
          ? Product.fromJson(Map<String, dynamic>.from(json['products'] as Map))
          : Product(id: '', name: 'Unknown', description: '', price: 0),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'user_id': userId,
      'product_id': product.id,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'quantity': quantity,
    };
  }
}
