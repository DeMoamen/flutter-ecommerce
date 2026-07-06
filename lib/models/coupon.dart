class Coupon {
  final String id;
  final String code;
  final double discountPercentage;
  final double minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.minOrderAmount,
    this.maxUses,
    required this.usedCount,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      maxUses: json['max_uses'] as int?,
      usedCount: json['used_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_percentage': discountPercentage,
      'min_order_amount': minOrderAmount,
      'max_uses': maxUses,
      'used_count': usedCount,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'code': code,
      'discount_percentage': discountPercentage,
      'min_order_amount': minOrderAmount,
      'max_uses': maxUses,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'code': code,
      'discount_percentage': discountPercentage,
      'min_order_amount': minOrderAmount,
      'max_uses': maxUses,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
