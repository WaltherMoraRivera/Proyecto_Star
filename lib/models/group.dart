class Group {
  final String id;
  final String name;
  final String administratorId;
  final List<String> memberIds;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.administratorId,
    required this.memberIds,
    required this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? administratorId,
    List<String>? memberIds,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      administratorId: administratorId ?? this.administratorId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'administratorId': administratorId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      administratorId: json['administratorId'],
      memberIds: List<String>.from(json['memberIds']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
