import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentStatus { pending, paid, overdue }

enum PaymentMethod { mpesa, bankTransfer, cash }

class Payment {
  final String id;
  final String tenantId;
  final String tenant;
  final String unit;
  final double amount;
  final String type; // Rent, Deposit, Utilities, etc.
  final String status; // Pending, Paid, Overdue
  final String paymentMethod; // M-Pesa, Bank Transfer, Cash
  final String? transactionId;
  final String dueDate;
  final String? paidDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.tenant,
    required this.unit,
    required this.amount,
    required this.type,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.dueDate,
    this.paidDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      tenant: json['tenant'] ?? '',
      unit: json['unit'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'Rent',
      status: json['status'] ?? 'Pending',
      paymentMethod: json['paymentMethod'] ?? 'M-Pesa',
      transactionId: json['transactionId'],
      dueDate: json['dueDate'] ?? '',
      paidDate: json['paidDate'],
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['createdAt'] ?? DateTime.now().toIso8601String(),
              ),
      updatedAt:
          json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(
                json['updatedAt'] ?? DateTime.now().toIso8601String(),
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'tenant': tenant,
      'unit': unit,
      'amount': amount,
      'type': type,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'dueDate': dueDate,
      'paidDate': paidDate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? tenantId,
    String? tenant,
    String? unit,
    double? amount,
    String? type,
    String? status,
    String? paymentMethod,
    String? transactionId,
    String? dueDate,
    String? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      tenant: tenant ?? this.tenant,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (status == 'Paid') return false;
    try {
      final due = DateTime.parse(dueDate);
      return DateTime.now().isAfter(due);
    } catch (e) {
      return false;
    }
  }

  String get formattedAmount {
    return 'KSh ${amount.toStringAsFixed(0)}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
