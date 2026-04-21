class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String userId;
  final String? assignedTo;
  final String? assignedName;
  final DateTime createdAt;
  final String? imageUrl;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
    DateTime? createdAt,
    this.assignedTo,
    this.assignedName,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();


  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Open',
      userId: json['user_id']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString(),
      assignedName: json['helpdesk']?['name']?.toString(),
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}