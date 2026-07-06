class PromoBanner {
  final String id;
  final String label;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? productId; // optional, to navigate to product

  PromoBanner({
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.productId,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id'].toString(),
      label: json['label'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      imageUrl: json['image_url'] as String,
      productId: json['product_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'product_id': productId,
    };
  }
}
