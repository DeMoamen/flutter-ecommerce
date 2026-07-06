class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    this.userName = 'مستخدم',
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String name = 'مستخدم';
    // Support both direct 'user_name' column and joined 'users' object
    if (json['user_name'] != null && (json['user_name'] as String).isNotEmpty) {
      name = json['user_name'];
    } else if (json['users'] != null && json['users']['name'] != null) {
      name = json['users']['name'];
    }

    return Review(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      userId: json['user_id'].toString(),
      userName: name,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
    };
  }
}
