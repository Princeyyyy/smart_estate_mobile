enum PaymentStatus { pending, processing, completed, failed, cancelled }

enum PaymentMethod { mpesa, card, bankTransfer, cash }

class Payment {
  final String id;
  final String userId;
  final String? unitNumber;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String description;
  final String? reference;
  final String? receiptUrl;
  final DateTime dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    this.unitNumber,
    required this.amount,
    required this.method,
    required this.status,
    required this.description,
    this.reference,
    this.receiptUrl,
    required this.dueDate,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      unitNumber: json['unitNumber'],
      amount: json['amount'].toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.mpesa,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      description: json['description'],
      reference: json['reference'],
      receiptUrl: json['receiptUrl'],
      dueDate: DateTime.parse(json['dueDate']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'unitNumber': unitNumber,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'description': description,
      'reference': reference,
      'receiptUrl': receiptUrl,
      'dueDate': dueDate.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Payment copyWith({
    String? id,
    String? userId,
    String? unitNumber,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? description,
    String? reference,
    String? receiptUrl,
    DateTime? dueDate,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      unitNumber: unitNumber ?? this.unitNumber,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != PaymentStatus.completed;
  }

  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
