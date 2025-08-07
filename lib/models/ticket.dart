import 'package:cloud_firestore/cloud_firestore.dart';

class TicketResponse {
  final String message;
  final String author;
  final DateTime timestamp;

  TicketResponse({
    required this.message,
    required this.author,
    required this.timestamp,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    return TicketResponse(
      message: json['message'] ?? '',
      author: json['author'] ?? '',
      timestamp:
          json['timestamp'] is Timestamp
              ? (json['timestamp'] as Timestamp).toDate()
              : DateTime.parse(
                json['timestamp'] ?? DateTime.now().toIso8601String(),
              ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'author': author,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class Ticket {
  final String id;
  final String title;
  final String description;
  final String category; // Plumbing, Electrical, General, etc.
  final String priority; // Low, Medium, High, Urgent
  final String status; // Pending, In Progress, Resolved
  final String submittedBy;
  final String tenantId;
  final String unit;
  final List<TicketResponse> responses;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.submittedBy,
    required this.tenantId,
    required this.unit,
    required this.responses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'Pending',
      submittedBy: json['submittedBy'] ?? '',
      tenantId: json['tenantId'] ?? '',
      unit: json['unit'] ?? '',
      responses:
          (json['responses'] as List<dynamic>? ?? [])
              .map((response) => TicketResponse.fromJson(response))
              .toList(),
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
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'submittedBy': submittedBy,
      'tenantId': tenantId,
      'unit': unit,
      'responses': responses.map((response) => response.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? submittedBy,
    String? tenantId,
    String? unit,
    List<TicketResponse>? responses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      submittedBy: submittedBy ?? this.submittedBy,
      tenantId: tenantId ?? this.tenantId,
      unit: unit ?? this.unit,
      responses: responses ?? this.responses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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
