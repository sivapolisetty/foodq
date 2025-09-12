class FoodLibraryItem {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? imagePrompt;
  final String? r2ImageKey;
  final String? cdnUrl;
  final int prepTimeMinutes;
  final String servingSize;
  final String basePriceRange;
  final List<String> tags;
  final String? aiPromptUsed;
  final String? aiModelVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdByAdminId;
  final bool isActive;
  final int usageCount;

  const FoodLibraryItem({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.imagePrompt,
    this.r2ImageKey,
    this.cdnUrl,
    required this.prepTimeMinutes,
    required this.servingSize,
    required this.basePriceRange,
    this.tags = const [],
    this.aiPromptUsed,
    this.aiModelVersion,
    required this.createdAt,
    required this.updatedAt,
    this.createdByAdminId,
    this.isActive = true,
    this.usageCount = 0,
  });

  factory FoodLibraryItem.fromJson(Map<String, dynamic> json) {
    return FoodLibraryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      imagePrompt: json['image_prompt'] as String?,
      r2ImageKey: json['r2_image_key'] as String?,
      cdnUrl: json['cdn_url'] as String?,
      prepTimeMinutes: json['prep_time_minutes'] as int,
      servingSize: json['serving_size'] as String,
      basePriceRange: json['base_price_range'] as String,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      aiPromptUsed: json['ai_prompt_used'] as String?,
      aiModelVersion: json['ai_model_version'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdByAdminId: json['created_by_admin_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      usageCount: json['usage_count'] as int? ?? 0,
    );
  }

  /// Get the best available image URL with CORS support
  String? get bestImageUrl {
    // Import the image service at the top of the file when needed
    final url = cdnUrl ?? imageUrl;
    if (url == null) return null;
    
    // Replace CDN domain with CORS-enabled worker URL
    if (url.startsWith('https://cdn.foodqapp.com/')) {
      return url.replaceFirst('https://cdn.foodqapp.com/', 
                             'https://foodq-cdn.sivapolisetty813.workers.dev/');
    }
    
    return url;
  }

  /// Parse base price range to get minimum and maximum prices
  (double?, double?) get priceRange {
    try {
      // Remove currency symbols and clean the string
      final cleanRange = basePriceRange.replaceAll(RegExp(r'[₹\$¥€£]'), '').trim();
      
      if (cleanRange.contains('-')) {
        final parts = cleanRange.split('-');
        if (parts.length == 2) {
          final minPrice = double.tryParse(parts[0].trim());
          final maxPrice = double.tryParse(parts[1].trim());
          return (minPrice, maxPrice);
        }
      } else {
        // Single price
        final price = double.tryParse(cleanRange);
        return (price, price);
      }
    } catch (e) {
      // Return null values if parsing fails
    }
    return (null, null);
  }

  /// Get minimum price from base_price_range
  double? get minPrice => priceRange.$1;

  /// Get maximum price from base_price_range
  double? get maxPrice => priceRange.$2;

  /// Get average price from base_price_range
  double? get averagePrice {
    final (min, max) = priceRange;
    if (min != null && max != null) {
      return (min + max) / 2;
    }
    return min ?? max;
  }

  /// Check if item matches search query (fuzzy search)
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    final lowerName = name.toLowerCase();
    final lowerDescription = description.toLowerCase();
    final lowerTags = tags.join(' ').toLowerCase();
    
    // Check for exact or partial matches
    return lowerName.contains(lowerQuery) || 
           lowerDescription.contains(lowerQuery) || 
           lowerTags.contains(lowerQuery) ||
           // Check for word-by-word match
           lowerQuery.split(' ').every((word) => 
             lowerName.contains(word) || lowerDescription.contains(word)
           );
  }

  /// Convert food library item to deal data for form population
  Map<String, dynamic> toDealFormData() {
    return {
      'title': name,
      'description': description,
      'original_price': maxPrice ?? averagePrice ?? 0.0,
      'discounted_price': minPrice ?? averagePrice ?? 0.0,
      'image_url': bestImageUrl,
      'allergen_info': null, // Food library doesn't have allergen info
      'food_library_reference': id, // Keep reference to food library item
    };
  }
}