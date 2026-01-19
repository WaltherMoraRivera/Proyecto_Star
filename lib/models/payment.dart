enum PaymentStatus {
  pending,
  approved,
  rejected,
  paid,
}

enum PaymentType {
  total,
  partial,
}

class Payment {
  final String id;
  final String userId;
  final String groupId;
  final int starsRequested;
  final double amount;
  final PaymentType type;
  final PaymentStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? notes;

  Payment({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.starsRequested,
    required this.amount,
    required this.type,
    this.status = PaymentStatus.pending,
    required this.requestedAt,
    this.processedAt,
    this.processedBy,
    this.notes,
  });

  Payment copyWith({
    String? id,
    String? userId,
    String? groupId,
    int? starsRequested,
    double? amount,
    PaymentType? type,
    PaymentStatus? status,
    DateTime? requestedAt,
    DateTime? processedAt,
    String? processedBy,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      starsRequested: starsRequested ?? this.starsRequested,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'starsRequested': starsRequested,
      'amount': amount,
      'type': type.toString(),
      'status': status.toString(),
      'requestedAt': requestedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'processedBy': processedBy,
      'notes': notes,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      groupId: json['groupId'],
      starsRequested: json['starsRequested'],
      amount: json['amount'],
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      requestedAt: DateTime.parse(json['requestedAt']),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      processedBy: json['processedBy'],
      notes: json['notes'],
    );
  }

  static PaymentType _parseType(String type) {
    return type == 'PaymentType.total' ? PaymentType.total : PaymentType.partial;
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status) {
      case 'PaymentStatus.approved':
        return PaymentStatus.approved;
      case 'PaymentStatus.rejected':
        return PaymentStatus.rejected;
      case 'PaymentStatus.paid':
        return PaymentStatus.paid;
      default:
        return PaymentStatus.pending;
    }
  }
}
