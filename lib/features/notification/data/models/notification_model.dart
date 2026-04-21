class NotificationModel {
  final String id; 
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "user_id": userId,
      "title": title,
      "message": message,
      "is_read": isRead,
      "created_at": createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map["id"].toString(),
      userId: map["user_id"] ?? "",
      title: map["title"] ?? "No Title",
      message: map["message"] ?? "No Message",
      isRead: map["is_read"] ?? false,
      createdAt: map["created_at"] ?? DateTime.now().toString(),
    );
  }
}