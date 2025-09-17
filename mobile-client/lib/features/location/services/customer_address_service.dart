import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../../../core/services/address_service.dart';

class CustomerAddress {
  final String id;
  final String userId;
  final String formattedAddress;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final bool isPrimary;
  final String addressType;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerAddress({
    required this.id,
    required this.userId,
    required this.formattedAddress,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    this.placeId,
    required this.isPrimary,
    required this.addressType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '', // May not be present in JSONB response
      formattedAddress: json['formatted_address'] as String,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      country: json['country'] as String? ?? 'US',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['place_id'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? 'pickup_location',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'formatted_address': formattedAddress,
      'street': street,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'is_primary': isPrimary,
      'address_type': addressType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from PlaceDetails
  static CustomerAddress fromPlaceDetails(
    String userId, 
    PlaceDetails placeDetails, {
    bool isPrimary = true,
    String addressType = 'takeaway',
  }) {
    return CustomerAddress(
      id: '', // Will be set by database
      userId: userId,
      formattedAddress: placeDetails.formattedAddress,
      street: placeDetails.street,
      city: placeDetails.city,
      state: placeDetails.state,
      zipCode: placeDetails.zipCode,
      country: placeDetails.country.isNotEmpty ? placeDetails.country : 'US',
      latitude: placeDetails.latitude,
      longitude: placeDetails.longitude,
      placeId: placeDetails.placeId,
      isPrimary: isPrimary,
      addressType: addressType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CustomerAddress(id: $id, address: $formattedAddress, isPrimary: $isPrimary)';
  }
}

class CustomerAddressResponse {
  final List<CustomerAddress> addresses;
  final CustomerAddress? primaryAddress;

  CustomerAddressResponse({
    required this.addresses,
    this.primaryAddress,
  });

  factory CustomerAddressResponse.fromJson(Map<String, dynamic> json) {
    final addressesList = (json['addresses'] as List? ?? [])
        .map((addr) => CustomerAddress.fromJson(addr))
        .toList();

    CustomerAddress? primary;
    if (json['primary_address'] != null) {
      primary = CustomerAddress.fromJson(json['primary_address']);
    }

    return CustomerAddressResponse(
      addresses: addressesList,
      primaryAddress: primary,
    );
  }
}

class CustomerAddressService {
  static const String _baseEndpoint = '/users';

  /// Get all saved addresses for a user
  static Future<CustomerAddressResponse?> getUserAddresses(String userId) async {
    try {
      print('📍 ADDRESS SERVICE: Fetching addresses for user: $userId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}$_baseEndpoint/$userId/addresses');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headersWithOptionalAuth,
      );

      print('📍 ADDRESS SERVICE: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final addressResponse = CustomerAddressResponse.fromJson(data['data']);
          print('📍 ADDRESS SERVICE: Found ${addressResponse.addresses.length} addresses');
          print('📍 ADDRESS SERVICE: Primary address: ${addressResponse.primaryAddress?.formattedAddress ?? 'None'}');
          return addressResponse;
        }
      } else {
        final errorData = json.decode(response.body);
        print('❌ ADDRESS SERVICE: API error: ${errorData['error']}');
      }
      
      return null;
    } catch (e) {
      print('❌ ADDRESS SERVICE: Error fetching addresses: $e');
      return null;
    }
  }

  /// Save a new address or update existing one
  static Future<CustomerAddress?> saveAddress({
    required String userId,
    required String formattedAddress,
    String street = '',
    String city = '',
    String state = '',
    String zipCode = '',
    String country = 'US',
    double? latitude,
    double? longitude,
    String? placeId,
    bool isPrimary = true,
    String addressType = 'takeaway',
  }) async {
    try {
      print('📍 ADDRESS SERVICE: Saving address for user: $userId');
      print('📍 ADDRESS SERVICE: Address: $formattedAddress');
      print('📍 ADDRESS SERVICE: Is primary: $isPrimary');
      
      final url = Uri.parse('${ApiConfig.baseUrl}$_baseEndpoint/$userId/addresses');
      
      final requestBody = {
        'formatted_address': formattedAddress,
        'street': street,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'place_id': placeId,
        'is_primary': isPrimary,
        'address_type': addressType,
      };

      final response = await http.post(
        url,
        headers: ApiConfig.headersWithOptionalAuth,
        body: json.encode(requestBody),
      );

      print('📍 ADDRESS SERVICE: Save response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data']?['address'] != null) {
          final savedAddress = CustomerAddress.fromJson(data['data']['address']);
          print('📍 ADDRESS SERVICE: Address saved successfully: ${savedAddress.id}');
          return savedAddress;
        }
      } else {
        final errorData = json.decode(response.body);
        print('❌ ADDRESS SERVICE: Save error: ${errorData['error']}');
      }
      
      return null;
    } catch (e) {
      print('❌ ADDRESS SERVICE: Error saving address: $e');
      return null;
    }
  }

  /// Save address from PlaceDetails
  static Future<CustomerAddress?> saveAddressFromPlace({
    required String userId,
    required PlaceDetails placeDetails,
    bool isPrimary = true,
    String addressType = 'takeaway',
  }) async {
    return saveAddress(
      userId: userId,
      formattedAddress: placeDetails.formattedAddress,
      street: placeDetails.street,
      city: placeDetails.city,
      state: placeDetails.state,
      zipCode: placeDetails.zipCode,
      country: placeDetails.country.isNotEmpty ? placeDetails.country : 'US',
      latitude: placeDetails.latitude,
      longitude: placeDetails.longitude,
      placeId: placeDetails.placeId,
      isPrimary: isPrimary,
      addressType: addressType,
    );
  }

  /// Delete a specific address
  static Future<bool> deleteAddress(String userId, String addressId) async {
    try {
      print('📍 ADDRESS SERVICE: Deleting address: $addressId for user: $userId');
      
      final url = Uri.parse('${ApiConfig.baseUrl}$_baseEndpoint/$userId/addresses/$addressId');
      
      final response = await http.delete(
        url,
        headers: ApiConfig.headersWithOptionalAuth,
      );

      print('📍 ADDRESS SERVICE: Delete response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('📍 ADDRESS SERVICE: Address deleted successfully');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ ADDRESS SERVICE: Error deleting address: $e');
      return false;
    }
  }

  /// Get primary address for a user
  static Future<CustomerAddress?> getPrimaryAddress(String userId) async {
    final response = await getUserAddresses(userId);
    return response?.primaryAddress;
  }
}