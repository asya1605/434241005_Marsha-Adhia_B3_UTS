class UserProfileModel {
  final String id;
  final String name;
  final String role;
  final DateTime? createdAt;
  final bool isActive;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.role,
    this.createdAt,
    this.isActive = true,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: (json['display_name'] as String?) ?? (json['name'] as String?) ?? 'No Name',
      role: (json['role'] as String?) ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}
