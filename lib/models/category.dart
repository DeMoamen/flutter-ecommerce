class Category {
  final String id;
  final String name;
  final String iconName;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      iconName: json['icon_name'] as String? ?? 'folder',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'icon_name': iconName,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'icon_name': iconName,
    };
  }
}
