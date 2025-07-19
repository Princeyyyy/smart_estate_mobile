enum MaintenanceStatus { pending, inProgress, completed, cancelled }

enum MaintenanceType {
  plumbing,
  electrical,
  hvac,
  painting,
  flooring,
  appliances,
  security,
  cleaning,
  other,
}

class MaintenanceRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final String? unitNumber;
  final List<String> images;
  final String? assignedTo;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? completionNotes;
  final double? cost;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.unitNumber,
    required this.images,
    this.assignedTo,
    this.scheduledDate,
    this.completedDate,
    this.completionNotes,
    this.cost,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MaintenanceType.other,
      ),
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MaintenanceStatus.pending,
      ),
      unitNumber: json['unitNumber'],
      images: List<String>.from(json['images'] ?? []),
      assignedTo: json['assignedTo'],
      scheduledDate:
          json['scheduledDate'] != null
              ? DateTime.parse(json['scheduledDate'])
              : null,
      completedDate:
          json['completedDate'] != null
              ? DateTime.parse(json['completedDate'])
              : null,
      completionNotes: json['completionNotes'],
      cost: json['cost']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'unitNumber': unitNumber,
      'images': images,
      'assignedTo': assignedTo,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'completionNotes': completionNotes,
      'cost': cost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MaintenanceRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    MaintenanceType? type,
    MaintenanceStatus? status,
    String? unitNumber,
    List<String>? images,
    String? assignedTo,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? completionNotes,
    double? cost,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      unitNumber: unitNumber ?? this.unitNumber,
      images: images ?? this.images,
      assignedTo: assignedTo ?? this.assignedTo,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      completionNotes: completionNotes ?? this.completionNotes,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    return type.name.split(RegExp(r'(?=[A-Z])')).join(' ').toLowerCase();
  }

  String get statusDisplayName {
    return status.name.split(RegExp(r'(?=[A-Z])')).join(' ').toLowerCase();
  }
}
