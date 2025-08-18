import '../../../shared/models/deal.dart';
import '../../../shared/models/deal_result.dart';
import '../models/restaurant.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/api_config.dart';
import 'dart:developer' as developer;

class DealService {
  // Remove Supabase dependency - now using Cloudflare Worker API
  DealService();

  /// Create a new deal with comprehensive validation
  Future<DealResult> createDeal({
    required String businessId,
    required String title,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required int quantityAvailable,
    required DateTime expiresAt,
    String? imageUrl,
    String? allergenInfo,
  }) async {
    try {
      // Comprehensive input validation
      final validationError = _validateDealInput(
        businessId: businessId,
        title: title,
        originalPrice: originalPrice,
        discountedPrice: discountedPrice,
        quantityAvailable: quantityAvailable,
        expiresAt: expiresAt,
      );

      if (validationError != null) {
        return DealResult.error(message: validationError, code: 'VALIDATION_ERROR');
      }

      final dealData = {
        'business_id': businessId,
        'title': title.trim(),
        'description': description.trim(),
        'original_price': originalPrice,
        'discounted_price': discountedPrice,
        'quantity_available': quantityAvailable,
        'image_url': imageUrl?.trim(),
        'allergen_info': allergenInfo?.trim(),
        'expires_at': expiresAt.toIso8601String(),
      };

      final response = await ApiService.post<dynamic>(
        ApiConfig.dealsEndpoint,
        body: dealData,
      );

      if (response.success && response.data != null) {
        // The API response structure is { "success": true, "data": { deal_object } }
        // So response.data already contains the deal object directly
        final deal = Deal.fromJson(response.data as Map<String, dynamic>);
        return DealResult.success(deal: deal);
      } else {
        return DealResult.error(
          message: response.error ?? 'Failed to create deal',
          code: response.code ?? 'API_ERROR',
        );
      }

    } catch (e) {
      return DealResult.error(
        message: 'Unexpected error creating deal: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Update an existing deal
  Future<DealResult> updateDeal(String dealId, Map<String, dynamic> updates) async {
    try {
      if (dealId.trim().isEmpty) {
        return const DealResult.error(
          message: 'Deal ID is required',
          code: 'INVALID_INPUT',
        );
      }

      // Validate pricing if being updated
      if (updates.containsKey('original_price') || updates.containsKey('discounted_price')) {
        final originalPrice = updates['original_price'] as double?;
        final discountedPrice = updates['discounted_price'] as double?;
        
        if (originalPrice != null && discountedPrice != null) {
          if (discountedPrice >= originalPrice) {
            return const DealResult.error(
              message: 'Discounted price must be less than original price',
              code: 'INVALID_PRICING',
            );
          }
        }
      }

      final response = await ApiService.put<dynamic>(
        '${ApiConfig.dealsEndpoint}/$dealId',
        body: updates,
      );

      if (response.success && response.data != null) {
        // The API response structure is { "success": true, "data": { deal_object } }
        // So response.data already contains the deal object directly
        final deal = Deal.fromJson(response.data as Map<String, dynamic>);
        return DealResult.success(deal: deal);
      } else {
        return DealResult.error(
          message: response.error ?? 'Failed to update deal',
          code: response.code ?? 'API_ERROR',
        );
      }

    } catch (e) {
      return DealResult.error(
        message: 'Unexpected error updating deal: ${e.toString()}',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Get deals for a specific business
  /// If no businessId provided, returns deals for authenticated user's businesses
  Future<List<Deal>> getDealsByBusinessId([String? businessId]) async {
    print('🚨 DEALSERVICE: getDealsByBusinessId called with businessId: $businessId');
    try {
      final queryParams = <String, String>{
        'limit': '100',
        'offset': '0',
      };
      
      // Only add business_id filter if specifically provided
      if (businessId != null && businessId.trim().isNotEmpty) {
        queryParams['business_id'] = businessId;
      }

      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: queryParams,
      );

      if (response.success && response.data != null) {
        print('🔴🔴🔴 DEAL_SERVICE_DEBUG: response.data = ${response.data}');
        print('🔴🔴🔴 DEAL_SERVICE_DEBUG: response.data type = ${response.data.runtimeType}');
        
        // Check if response.data is already a List (direct array response)
        final dynamic rawData = response.data;
        final List<dynamic> dealsData;
        
        if (rawData is List) {
          print('🔴🔴🔴 DEAL_SERVICE_DEBUG: response.data is already a List!');
          dealsData = rawData;
        } else if (rawData is Map && rawData['data'] != null) {
          print('🔴🔴🔴 DEAL_SERVICE_DEBUG: response.data is a Map with data field');
          dealsData = rawData['data'] as List<dynamic>;
        } else {
          print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Unexpected response format!');
          return [];
        }
        print('🔴🔴🔴 DEAL_SERVICE_DEBUG: dealsData length = ${dealsData.length}');
        
        final List<Deal> parsedDeals = [];
        
        for (int i = 0; i < dealsData.length; i++) {
          print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Parsing deal $i...');
          try {
            final dealJson = dealsData[i];
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: dealJson = $dealJson');
            
            if (dealJson == null) {
              print('🔴🔴🔴 DEAL_SERVICE_DEBUG: dealJson at index $i is NULL!');
              continue;
            }
            
            if (dealJson is! Map<String, dynamic>) {
              print('🔴🔴🔴 DEAL_SERVICE_DEBUG: dealJson at index $i is not Map<String, dynamic>! Type: ${dealJson.runtimeType}');
              continue;
            }
            
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Creating Deal from JSON...');
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: dealJson keys: ${dealJson.keys.toList()}');
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: quantity_available type: ${dealJson['quantity_available'].runtimeType}, value: ${dealJson['quantity_available']}');
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: quantity_sold type: ${dealJson['quantity_sold'].runtimeType}, value: ${dealJson['quantity_sold']}');
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: discount_percentage type: ${dealJson['discount_percentage'].runtimeType}, value: ${dealJson['discount_percentage']}');
            
            // Sanitize numeric fields that might come as strings
            final sanitizedJson = Map<String, dynamic>.from(dealJson);
            _sanitizeNumericFields(sanitizedJson);
            
            final deal = Deal.fromJson(sanitizedJson);
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Deal created successfully: ${deal.title} (id: ${deal.id})');
            parsedDeals.add(deal);
          } catch (e, stackTrace) {
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: EXCEPTION parsing deal $i: $e');
            print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Stack trace: $stackTrace');
          }
        }
        
        print('🔴🔴🔴 DEAL_SERVICE_DEBUG: Total parsed deals = ${parsedDeals.length}');
        return parsedDeals;
      } else {
        developer.log('Failed to fetch business deals: ${response.error}');
        return [];
      }

    } catch (e) {
      developer.log('Error fetching business deals: $e');
      return [];
    }
  }

  /// Get active deals with filtering and pagination
  /// For business users: automatically returns only their deals
  /// For customers: returns all public deals 
  Future<List<Deal>> getActiveDeals({int limit = 20, int offset = 0}) async {
    try {
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      if (response.success && response.data != null) {
        // response.data is already the deals array, not a map with a 'data' field
        final dealsData = response.data as List<dynamic>;
        return dealsData
            .map((json) {
              // Sanitize numeric fields that might come as strings
              final sanitizedJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
              _sanitizeNumericFields(sanitizedJson);
              return Deal.fromJson(sanitizedJson);
            })
            .toList();
      } else {
        developer.log('Failed to fetch active deals: ${response.error}');
        return [];
      }

    } catch (e) {
      developer.log('Error fetching active deals: $e');
      return [];
    }
  }

  /// Deactivate a deal (mark as expired)
  Future<bool> deactivateDeal(String dealId) async {
    try {
      if (dealId.trim().isEmpty) {
        return false;
      }

      final response = await ApiService.delete<dynamic>(
        '${ApiConfig.dealsEndpoint}/$dealId',
      );

      return response.success;
    } catch (e) {
      developer.log('Error deactivating deal: $e');
      return false;
    }
  }

  /// Increment quantity sold (for order processing)
  Future<bool> incrementQuantitySold(String dealId, int quantity) async {
    try {
      if (dealId.trim().isEmpty || quantity <= 0) {
        return false;
      }

      // Use the update endpoint to increment quantity sold
      final response = await ApiService.put<dynamic>(
        '${ApiConfig.dealsEndpoint}/$dealId',
        body: {
          'increment_quantity_sold': quantity,
        },
      );

      return response.success;
    } catch (e) {
      developer.log('Error incrementing quantity sold: $e');
      return false;
    }
  }

  /// Get deal by ID
  Future<Deal?> getDealById(String dealId) async {
    try {
      if (dealId.trim().isEmpty) {
        return null;
      }

      final response = await ApiService.get<dynamic>(
        '${ApiConfig.dealsEndpoint}/$dealId',
      );

      if (response.success && response.data != null) {
        // The API response structure is { "success": true, "data": { deal_object } }
        // So response.data already contains the deal object directly
        return Deal.fromJson(response.data as Map<String, dynamic>);
      } else {
        developer.log('Failed to fetch deal by ID: ${response.error}');
        return null;
      }

    } catch (e) {
      developer.log('Error fetching deal by ID: $e');
      return null;
    }
  }

  /// Get deals by urgency level for notifications
  Future<List<Deal>> getDealsByUrgency(DealUrgency urgency) async {
    try {
      final deals = await getActiveDeals(limit: 100);
      return deals.where((deal) => deal.urgency == urgency).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get expiring deals (for notification system)
  Future<List<Deal>> getExpiringDeals({int hoursThreshold = 2}) async {
    try {
      // Use the pickup_now filter to get deals expiring soon
      return fetchCustomerDeals(
        filter: 'pickup_now',
        limit: 100,
      );
    } catch (e) {
      developer.log('Error fetching expiring deals: $e');
      return [];
    }
  }

  /// Get almost sold out deals (for notification system)
  Future<List<Deal>> getAlmostSoldOutDeals({double thresholdPercentage = 20.0}) async {
    try {
      final deals = await getActiveDeals(limit: 100);
      return deals.where((deal) {
        if (deal.quantityAvailable <= 0) return false;
        final remainingPercentage = (deal.remainingQuantity / deal.quantityAvailable) * 100;
        return remainingPercentage <= thresholdPercentage && deal.remainingQuantity > 0;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Validate deal input data
  String? _validateDealInput({
    required String businessId,
    required String title,
    required double originalPrice,
    required double discountedPrice,
    required int quantityAvailable,
    required DateTime expiresAt,
  }) {
    if (businessId.trim().isEmpty) {
      return 'Business ID is required';
    }

    if (title.trim().isEmpty) {
      return 'Title is required';
    }

    if (title.trim().length < 3) {
      return 'Title must be at least 3 characters long';
    }

    if (originalPrice <= 0) {
      return 'Original price must be greater than 0';
    }

    if (discountedPrice <= 0) {
      return 'Discounted price must be greater than 0';
    }

    if (discountedPrice >= originalPrice) {
      return 'Discounted price must be less than original price';
    }

    if (quantityAvailable <= 0) {
      return 'Quantity available must be greater than 0';
    }

    if (expiresAt.isBefore(DateTime.now())) {
      return 'Expiration time must be in the future';
    }

    // Ensure reasonable expiration time (not more than 7 days from now)
    final maxExpiration = DateTime.now().add(const Duration(days: 7));
    if (expiresAt.isAfter(maxExpiration)) {
      return 'Expiration time cannot be more than 7 days from now';
    }

    return null;
  }

  // ==================== CUSTOMER-FACING METHODS ====================

  /// Fetch deals for customer home page with filters
  Future<List<Deal>> fetchCustomerDeals({
    String? filter,
    double? userLat,
    double? userLng,
    int radiusKm = 10,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      print('🔄 DealService: Fetching customer deals with filter: $filter');
      print('🔗 API URL: ${ApiConfig.dealsUrl}');
      developer.log('Fetching customer deals with filter: $filter');

      final queryParameters = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      // Add filter parameter if provided
      if (filter != null) {
        queryParameters['filter'] = filter;
      }

      // Add location parameters for nearby filter
      if (filter == 'nearby' && userLat != null && userLng != null) {
        queryParameters['lat'] = userLat.toString();
        queryParameters['lng'] = userLng.toString();
      }

      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: queryParameters,
      );

      if (response.success && response.data != null) {
        print('🔍 DEBUG: response.data type = ${response.data.runtimeType}');
        
        // response.data is already the deals array, not a map with a 'data' field
        final dealsData = response.data as List<dynamic>;
        final deals = <Deal>[];
        
        for (int i = 0; i < dealsData.length; i++) {
          try {
            final json = dealsData[i] as Map<String, dynamic>;
            print('🔄 Processing deal $i: ${json['title']} (id: ${json['id']})');
            
            // Sanitize numeric fields that might come as strings
            final sanitizedJson = Map<String, dynamic>.from(json);
            _sanitizeNumericFields(sanitizedJson);
            
            final deal = Deal.fromJson(sanitizedJson);
            deals.add(deal);
            print('✅ Deal $i parsed successfully: ${deal.title}');
          } catch (e, stackTrace) {
            print('❌ Error parsing deal $i: $e');
            print('🔍 Stack trace: $stackTrace');
            print('🔍 Raw JSON: ${dealsData[i]}');
          }
        }

        print('✅ Successfully fetched ${deals.length} deals total');
        print('🔍 Deal titles: ${deals.map((d) => d.title).join(', ')}');
        developer.log('Successfully fetched ${deals.length} deals');
        return deals;
      } else {
        print('❌ Failed to fetch customer deals: ${response.error}');
        developer.log('Failed to fetch customer deals: ${response.error}');
        return [];
      }

    } catch (e) {
      print('💥 Error fetching customer deals: $e');
      developer.log('Error fetching customer deals: $e');
      rethrow;
    }
  }

  /// Search deals by query
  Future<List<Deal>> searchDeals(String query) async {
    if (query.isEmpty) {
      return fetchCustomerDeals();
    }

    try {
      developer.log('Searching deals with query: $query');
      
      final response = await ApiService.get<dynamic>(
        ApiConfig.dealsEndpoint,
        queryParameters: {
          'search': query,
          'limit': '50',
        },
      );

      if (response.success && response.data != null) {
        // response.data is already the deals array, not a map with a 'data' field
        final dealsData = response.data as List<dynamic>;
        final deals = dealsData
            .map((json) {
              // Sanitize numeric fields that might come as strings
              final sanitizedJson = Map<String, dynamic>.from(json as Map<String, dynamic>);
              _sanitizeNumericFields(sanitizedJson);
              return Deal.fromJson(sanitizedJson);
            })
            .toList();

        developer.log('Search returned ${deals.length} deals');
        return deals;
      } else {
        developer.log('Failed to search deals: ${response.error}');
        return [];
      }

    } catch (e) {
      developer.log('Error searching deals: $e');
      rethrow;
    }
  }

  /// Fetch nearby deals using location filtering
  Future<List<Deal>> fetchNearbyDeals({
    required double userLat,
    required double userLng,
    int radiusKm = 10,
    int limit = 50,
  }) async {
    try {
      developer.log('Fetching nearby deals for location: $userLat, $userLng');
      
      // Use the nearby filter through the Worker API
      return fetchCustomerDeals(
        filter: 'nearby',
        userLat: userLat,
        userLng: userLng,
        radiusKm: radiusKm,
        limit: limit,
      );
      
    } catch (e) {
      developer.log('Error fetching nearby deals: $e');
      rethrow;
    }
  }

  /// Sanitize numeric fields that might come as strings from the API
  void _sanitizeNumericFields(Map<String, dynamic> json) {
    // List of fields that should be numeric in Deal objects
    final numericFields = [
      'original_price',
      'discounted_price', 
      'discount_percentage',
      'quantity_available',
      'quantity_sold',
      'preparation_time'
    ];

    // List of fields that should be numeric in nested Restaurant objects
    final restaurantNumericFields = [
      'rating',
      'total_reviews',
      'latitude',
      'longitude'
    ];

    // Sanitize main deal fields
    for (final field in numericFields) {
      if (json.containsKey(field) && json[field] != null) {
        final value = json[field];
        if (value is String) {
          try {
            // Try to parse as number
            if (field.contains('price')) {
              json[field] = double.parse(value);
            } else {
              json[field] = int.parse(value);
            }
            print('🔧 SANITIZED: Converted $field from String "$value" to ${json[field].runtimeType}');
          } catch (e) {
            print('⚠️  WARNING: Could not parse $field value "$value" as number: $e');
          }
        }
      }
    }

    // Sanitize nested businesses/restaurant fields
    if (json.containsKey('businesses') && json['businesses'] is Map<String, dynamic>) {
      final businessJson = json['businesses'] as Map<String, dynamic>;
      
      for (final field in restaurantNumericFields) {
        if (businessJson.containsKey(field) && businessJson[field] != null) {
          final value = businessJson[field];
          if (value is String) {
            try {
              // rating, latitude, longitude should be double; total_reviews should be int
              if (field == 'total_reviews') {
                businessJson[field] = int.parse(value);
              } else {
                businessJson[field] = double.parse(value);
              }
              print('🔧 SANITIZED: Converted businesses.$field from String "$value" to ${businessJson[field].runtimeType}');
            } catch (e) {
              print('⚠️  WARNING: Could not parse businesses.$field value "$value" as number: $e');
            }
          }
        }
      }
    }
  }
}