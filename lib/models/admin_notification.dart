class AdminNotification {
  final String id;
  final String title;
  final String body;
  final String? targetUserId;
  final bool isSent;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.title,
    required this.body,
    this.targetUserId,
    required this.isSent,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      targetUserId: json['target_user_id'] as String?,
      isSent: json['is_sent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'target_user_id': targetUserId,
      'is_sent': isSent,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'body': body,
      'target_user_id': targetUserId,
      'is_sent': isSent,
    };
  }
}
