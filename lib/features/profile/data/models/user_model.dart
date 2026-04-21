class UserModel {

  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.createdAt,
  });

  /// Convert Object ke Map
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "created_at": createdAt,
    };
  }

  /// Convert Map ke Object
  factory UserModel.fromMap(Map<String, dynamic> map) {

    return UserModel(
      id: map["id"],
      name: map["name"],
      email: map["email"],
      password: map["password"],
      role: map["role"] ?? "user",
      createdAt: map["created_at"],
    );

  }

}