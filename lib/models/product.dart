class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final DateTime? createdAt;
  final double rating;
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = '',
    this.category = 'General',
    this.createdAt,
    this.rating = 0.0,
    this.isFeatured = false,
  });

  String get image => imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] as String? ?? json['image'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFeatured: _parseBool(json['is_featured']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final str = value.toString().toLowerCase().trim();
    return str == 'true' || str == 't' || str == '1' || str == 'yes';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'image': imageUrl,
      'category': category,
      'rating': rating,
      'is_featured': isFeatured,
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_featured': isFeatured,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_featured': isFeatured,
    };
  }
}
