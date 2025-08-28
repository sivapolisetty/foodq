import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class PlacePrediction {
  final String? description;
  final String? placeId;
  final String? mainText;
  final String? secondaryText;

  PlacePrediction({
    this.description,
    this.placeId,
    this.mainText,
    this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] as Map<String, dynamic>?;
    
    return PlacePrediction(
      description: json['description'] as String?,
      placeId: json['place_id'] as String?,
      mainText: structuredFormatting?['main_text'] as String?,
      secondaryText: structuredFormatting?['secondary_text'] as String?,
    );
  }
}

class PlaceDetails {
  final String formattedAddress;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String placeId;

  PlaceDetails({
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.placeId,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      formattedAddress: json['formatted_address'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['place_id'] as String? ?? '',
    );
  }
}

class AddressService {
  static Future<List<PlacePrediction>> getAddressSuggestions(String input) async {
    if (input.length < 2) {
      return [];
    }

    try {
      print('🔍 PLACES: Fetching address suggestions for: $input');
      
      final url = Uri.parse('${ApiConfig.baseUrl}/api/places/autocomplete');
      final queryParams = {
        'input': input,
        'language': 'en',
        'components': 'country:us',
      };
      
      final uri = url.replace(queryParameters: queryParams);
      
      print('🌐 PLACES: Making request to: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 PLACES: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final placesData = data['data'];
          final predictions = placesData['predictions'] as List?;
          
          if (predictions != null) {
            final suggestions = predictions
                .map((prediction) => PlacePrediction.fromJson(prediction))
                .toList();
            
            print('✅ PLACES: Found ${suggestions.length} suggestions');
            return suggestions;
          }
        } else {
          print('⚠️ PLACES: API returned error: ${data['error']}');
          // Return empty list for now - user can still type address manually
          return [];
        }
      } else {
        final errorData = json.decode(response.body);
        print('⚠️ PLACES: API error: ${errorData['error']}');
        // Return empty list for now - user can still type address manually
        return [];
      }
      
      print('⚠️ PLACES: No valid suggestions found');
      return [];
      
    } catch (e) {
      print('❌ PLACES: Error fetching suggestions: $e');
      return [];
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    print('🚀 [SERVICE] getPlaceDetails called with placeId: "$placeId"');
    
    if (placeId.isEmpty) {
      print('❌ [SERVICE] Place ID is empty, returning null');
      return null;
    }

    try {
      print('🔍 [SERVICE] Fetching place details for: $placeId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}/api/places/details');
      final queryParams = {
        'place_id': placeId,
      };
      
      final uri = url.replace(queryParameters: queryParams);
      
      print('🌐 [SERVICE] Making request to: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 [SERVICE] Response status: ${response.statusCode}');
      print('📄 [SERVICE] Response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        print('🔍 [SERVICE] Parsed JSON data: $data');
        
        if (data['success'] == true) {
          final placeData = data['data'];
          print('📦 [SERVICE] Place data received: $placeData');
          
          final placeDetails = PlaceDetails.fromJson(placeData);
          
          print('✅ [SERVICE] PlaceDetails object created successfully');
          print('🏠 [SERVICE] Formatted address: "${placeDetails.formattedAddress}"');
          print('🏙️ [SERVICE] Parsed components:');
          print('   - Street: "${placeDetails.street}"');
          print('   - City: "${placeDetails.city}"');
          print('   - State: "${placeDetails.state}"');
          print('   - ZIP: "${placeDetails.zipCode}"');
          print('   - Country: "${placeDetails.country}"');
          print('   - Coordinates: ${placeDetails.latitude}, ${placeDetails.longitude}');
          
          return placeDetails;
        } else {
          print('❌ [SERVICE] API returned success=false, error: ${data['error']}');
          return null;
        }
      } else {
        final errorData = json.decode(response.body);
        print('❌ [SERVICE] HTTP error ${response.statusCode}: ${errorData['error']}');
        return null;
      }
      
    } catch (e, stackTrace) {
      print('💥 [SERVICE] Exception in getPlaceDetails: $e');
      print('📍 [SERVICE] Stack trace: $stackTrace');
      return null;
    }
  }
}