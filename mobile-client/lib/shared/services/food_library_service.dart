import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_library_item.dart';
import '../../core/config/api_config.dart';

class FoodLibraryService {
  static String get _apiEndpoint => '${ApiConfig.baseUrl}/admin/food-library';

  /// Search food library items
  Future<List<FoodLibraryItem>> searchFoodLibraryItems({
    String? search,
    List<String>? tags,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse(_apiEndpoint).replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
      );

      print('🔍 Searching food library: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': 'test-api-key-2024', // TODO: Move to config
        },
      );

      print('📡 Food library search response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> itemsJson = jsonData['data'] ?? [];
          final items = itemsJson
              .map((json) => FoodLibraryItem.fromJson(json))
              .toList();
          
          print('✅ Found ${items.length} food library items');
          return items;
        } else {
          print('❌ API returned success=false: ${jsonData['error']}');
          throw Exception(jsonData['error'] ?? 'Unknown error');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to search food library: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Food library search error: $e');
      rethrow;
    }
  }

  /// Get all food library items (for local fuzzy search)
  Future<List<FoodLibraryItem>> getAllFoodLibraryItems() async {
    return await searchFoodLibraryItems(limit: 1000); // Get all items
  }

  /// Fuzzy search locally within provided items
  List<FoodLibraryItem> fuzzySearchLocal(
    List<FoodLibraryItem> items, 
    String query, {
    int limit = 5,
  }) {
    if (query.trim().isEmpty) return [];
    
    return items
        .where((item) => item.matchesSearch(query))
        .take(limit)
        .toList();
  }

  /// Combined search: first try local fuzzy search, then API search if no results
  Future<List<FoodLibraryItem>> smartSearch(
    String query, {
    List<FoodLibraryItem>? cachedItems,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];

    // First try local fuzzy search if we have cached items
    if (cachedItems != null && cachedItems.isNotEmpty) {
      final localResults = fuzzySearchLocal(cachedItems, query, limit: limit);
      if (localResults.isNotEmpty) {
        print('✅ Found ${localResults.length} items via local search');
        return localResults;
      }
    }

    // If no local results, try API search
    try {
      final apiResults = await searchFoodLibraryItems(
        search: query,
        limit: limit,
      );
      print('✅ Found ${apiResults.length} items via API search');
      return apiResults;
    } catch (e) {
      print('❌ API search failed, returning empty results: $e');
      return [];
    }
  }
}