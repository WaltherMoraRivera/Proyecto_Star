enum UserRole {
  administrator,
  user,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? groupId;
  final int accumulatedStars;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
    this.accumulatedStars = 0,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? groupId,
    int? accumulatedStars,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
      accumulatedStars: accumulatedStars ?? this.accumulatedStars,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'groupId': groupId,
      'accumulatedStars': accumulatedStars,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'UserRole.administrator'
          ? UserRole.administrator
          : UserRole.user,
      groupId: json['groupId'],
      accumulatedStars: json['accumulatedStars'] ?? 0,
    );
  }
}
