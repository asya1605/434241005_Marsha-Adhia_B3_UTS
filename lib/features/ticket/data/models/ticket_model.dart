export 'ticket_status_x.dart';

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String userId;
  final String category;
  final String priority;
  final String? assignedTo;
  final String? assignedName;
  final String? creatorName;
  final DateTime createdAt;
  final String? imageUrl;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.userId,
    this.category = 'General',
    this.priority = 'Medium',
    DateTime? createdAt,
    this.assignedTo,
    this.assignedName,
    this.creatorName,
    this.imageUrl,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Open',
      userId: json['user_id']?.toString() ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      assignedTo: json['assigned_to']?.toString(),
      assignedName: (json['helpdesk']?['display_name'] ?? json['helpdesk']?['name'])?.toString(),
      creatorName: (json['creator']?['display_name'] ?? json['creator']?['name'])?.toString(),
      imageUrl: json['image_url']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? userId,
    String? category,
    String? priority,
    DateTime? createdAt,
    String? assignedTo,
    String? assignedName,
    String? creatorName,
    String? imageUrl,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedName: assignedName ?? this.assignedName,
      creatorName: creatorName ?? this.creatorName,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'user_id': userId,
      'category': category,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'assigned_to': assignedTo,
      'image_url': imageUrl,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel.fromJson(map);
  }
}