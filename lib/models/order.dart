import 'cart_item.dart';

class Order {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String status;

  Order({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
    this.status = 'Processing',
  });

  factory Order.fromJson(Map<String, dynamic> json, List<CartItem> items) {
    return Order(
      id: json['id'] as String? ?? '',
      amount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      products: items,
      dateTime: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'Processing',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_amount': amount,
      'status': status,
    };
  }

  Map<String, dynamic> toInsertMap(String userId) {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': amount,
      'status': status,
      'created_at': dateTime.toIso8601String(),
    };
  }
}
