class Comment {
  final String id;
  final String ticketId;
  final String userId;
  final String message;
  final String role; 
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.role,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticket_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      message: json['message'] ?? '',
      role: json['role'] ?? 'user', 
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}