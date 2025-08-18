class Business {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final String? address;
  final String? phone;
  final String? email;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Business({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.ownerId,
    this.address,
    this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      ownerId: json['owner_id'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isActive: json['is_active'] ?? true,
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
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'owner_id': ownerId,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? ownerId,
    String? address,
    String? phone,
    String? email,
    double? latitude,
    double? longitude,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasLocation {
    return latitude != null && longitude != null;
  }

  @override
  String toString() {
    return 'Business{id: $id, name: $name, ownerId: $ownerId, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}