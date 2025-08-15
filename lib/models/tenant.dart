import 'package:cloud_firestore/cloud_firestore.dart';

class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String unit;
  final double rent;
  final String moveInDate;
  final String leaseLength;
  final String status; // Active, Inactive
  final String firebaseUid;
  final String defaultPassword;
  final bool hasChangedPassword;
  final String? oneSignalDeviceId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.unit,
    required this.rent,
    required this.moveInDate,
    required this.leaseLength,
    required this.status,
    required this.firebaseUid,
    required this.defaultPassword,
    required this.hasChangedPassword,
    this.oneSignalDeviceId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      unit: json['unit'] ?? '',
      rent: (json['rent'] ?? 0).toDouble(),
      moveInDate: json['moveInDate'] ?? '',
      leaseLength: json['leaseLength'] ?? '',
      status: json['status'] ?? 'Active',
      firebaseUid: json['firebaseUid'] ?? '',
      defaultPassword: json['defaultPassword'] ?? '',
      hasChangedPassword: json['hasChangedPassword'] ?? false,
      oneSignalDeviceId: json['oneSignalDeviceId'],
      notes: json['notes'],
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
      'email': email,
      'phone': phone,
      'unit': unit,
      'rent': rent,
      'moveInDate': moveInDate,
      'leaseLength': leaseLength,
      'status': status,
      'firebaseUid': firebaseUid,
      'defaultPassword': defaultPassword,
      'hasChangedPassword': hasChangedPassword,
      'oneSignalDeviceId': oneSignalDeviceId,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Tenant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? unit,
    double? rent,
    String? moveInDate,
    String? leaseLength,
    String? status,
    String? firebaseUid,
    String? defaultPassword,
    bool? hasChangedPassword,
    String? oneSignalDeviceId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      unit: unit ?? this.unit,
      rent: rent ?? this.rent,
      moveInDate: moveInDate ?? this.moveInDate,
      leaseLength: leaseLength ?? this.leaseLength,
      status: status ?? this.status,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      defaultPassword: defaultPassword ?? this.defaultPassword,
      hasChangedPassword: hasChangedPassword ?? this.hasChangedPassword,
      oneSignalDeviceId: oneSignalDeviceId ?? this.oneSignalDeviceId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
