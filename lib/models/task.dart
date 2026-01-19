enum TaskStatus {
  pending,
  completed,
  expired,
}

class Task {
  final String id;
  final String title;
  final String description;
  final int starReward; // 1-5 stars
  final String groupId;
  final DateTime createdAt;
  final DateTime deadline; // 48 hours from creation
  final String? assignedUserId;
  final TaskStatus status;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.starReward,
    required this.groupId,
    required this.createdAt,
    required this.deadline,
    this.assignedUserId,
    this.status = TaskStatus.pending,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? starReward,
    String? groupId,
    DateTime? createdAt,
    DateTime? deadline,
    String? assignedUserId,
    TaskStatus? status,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      starReward: starReward ?? this.starReward,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool isExpired() {
    return DateTime.now().isAfter(deadline) && status == TaskStatus.pending;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'starReward': starReward,
      'groupId': groupId,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'assignedUserId': assignedUserId,
      'status': status.toString(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      starReward: json['starReward'],
      groupId: json['groupId'],
      createdAt: DateTime.parse(json['createdAt']),
      deadline: DateTime.parse(json['deadline']),
      assignedUserId: json['assignedUserId'],
      status: _parseStatus(json['status']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  static TaskStatus _parseStatus(String status) {
    switch (status) {
      case 'TaskStatus.completed':
        return TaskStatus.completed;
      case 'TaskStatus.expired':
        return TaskStatus.expired;
      default:
        return TaskStatus.pending;
    }
  }
}
