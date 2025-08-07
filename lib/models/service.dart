import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String title;
  final String description;
  final String provider;
  final String category;
  final double price;
  final String priceType; // per service, per hour, etc.
  final String contact;
  final double rating;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.provider,
    required this.category,
    required this.price,
    required this.priceType,
    required this.contact,
    required this.rating,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      provider: json['provider'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      priceType: json['priceType'] ?? 'per service',
      contact: json['contact'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
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
      'provider': provider,
      'category': category,
      'price': price,
      'priceType': priceType,
      'contact': contact,
      'rating': rating,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Service copyWith({
    String? id,
    String? title,
    String? description,
    String? provider,
    String? category,
    double? price,
    String? priceType,
    String? contact,
    double? rating,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      provider: provider ?? this.provider,
      category: category ?? this.category,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      contact: contact ?? this.contact,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedPrice {
    return 'KSh ${price.toStringAsFixed(0)} $priceType';
  }
}
