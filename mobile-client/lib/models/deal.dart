class Deal {
  final String id;
  final String title;
  final String? description;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String businessId;
  final String? imageUrl;
  final bool isActive;
  final DateTime validFrom;
  final DateTime validUntil;
  final String? termsConditions;
  final int maxRedemptions;
  final int currentRedemptions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Deal({
    required this.id,
    required this.title,
    this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.businessId,
    this.imageUrl,
    required this.isActive,
    required this.validFrom,
    required this.validUntil,
    this.termsConditions,
    this.maxRedemptions = 0,
    this.currentRedemptions = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      originalPrice: (json['original_price'] ?? 0).toDouble(),
      discountedPrice: (json['discounted_price'] ?? 0).toDouble(),
      discountPercentage: json['discount_percentage'] ?? 0,
      businessId: json['business_id'] ?? '',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      validFrom: json['valid_from'] != null 
          ? DateTime.parse(json['valid_from']) 
          : DateTime.now(),
      validUntil: json['valid_until'] != null 
          ? DateTime.parse(json['valid_until']) 
          : DateTime.now().add(const Duration(days: 30)),
      termsConditions: json['terms_conditions'],
      maxRedemptions: json['max_redemptions'] ?? 0,
      currentRedemptions: json['current_redemptions'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'discount_percentage': discountPercentage,
      'business_id': businessId,
      'image_url': imageUrl,
      'is_active': isActive,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'terms_conditions': termsConditions,
      'max_redemptions': maxRedemptions,
      'current_redemptions': currentRedemptions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Deal copyWith({
    String? id,
    String? title,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    int? discountPercentage,
    String? businessId,
    String? imageUrl,
    bool? isActive,
    DateTime? validFrom,
    DateTime? validUntil,
    String? termsConditions,
    int? maxRedemptions,
    int? currentRedemptions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      businessId: businessId ?? this.businessId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      termsConditions: termsConditions ?? this.termsConditions,
      maxRedemptions: maxRedemptions ?? this.maxRedemptions,
      currentRedemptions: currentRedemptions ?? this.currentRedemptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(validFrom) && 
           now.isBefore(validUntil) &&
           (maxRedemptions == 0 || currentRedemptions < maxRedemptions);
  }

  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }

  double get savingsAmount {
    return originalPrice - discountedPrice;
  }

  @override
  String toString() {
    return 'Deal{id: $id, title: $title, originalPrice: $originalPrice, discountedPrice: $discountedPrice, discountPercentage: $discountPercentage, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Deal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}