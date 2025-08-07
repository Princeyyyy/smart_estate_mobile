import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String name;
  final String type; // Studio, 1-5 Bedroom, Bedsitter, etc.
  final double rent;
  final String status; // Vacant, Occupied, Maintenance
  final String? tenant; // null if vacant
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.name,
    required this.type,
    required this.rent,
    required this.status,
    this.tenant,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      status: json['status'] ?? 'Vacant',
      tenant: json['tenant'],
      description: json['description'],
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
      'name': name,
      'type': type,
      'rent': rent,
      'status': status,
      'tenant': tenant,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Property copyWith({
    String? id,
    String? name,
    String? type,
    double? rent,
    String? status,
    String? tenant,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rent: rent ?? this.rent,
      status: status ?? this.status,
      tenant: tenant ?? this.tenant,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
