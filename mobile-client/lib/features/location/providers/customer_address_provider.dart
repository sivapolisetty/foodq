import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/customer_address_service.dart';
import '../../../core/services/address_service.dart';
import 'location_preferences_provider.dart';

/// State class for customer addresses
class CustomerAddressState {
  final List<CustomerAddress> addresses;
  final CustomerAddress? primaryAddress;
  final bool isLoading;
  final String? error;

  const CustomerAddressState({
    this.addresses = const [],
    this.primaryAddress,
    this.isLoading = false,
    this.error,
  });

  CustomerAddressState copyWith({
    List<CustomerAddress>? addresses,
    CustomerAddress? primaryAddress,
    bool clearPrimaryAddress = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CustomerAddressState(
      addresses: addresses ?? this.addresses,
      primaryAddress: clearPrimaryAddress ? null : (primaryAddress ?? this.primaryAddress),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() {
    return 'CustomerAddressState(addresses: ${addresses.length}, primaryAddress: ${primaryAddress?.formattedAddress}, isLoading: $isLoading, error: $error)';
  }
}

/// Notifier for managing customer addresses
class CustomerAddressNotifier extends StateNotifier<CustomerAddressState> {
  CustomerAddressNotifier() : super(const CustomerAddressState());

  /// Load addresses from local persistence instead of API
  Future<void> loadAddresses(String userId) async {
    if (state.isLoading) return; // Prevent concurrent loads
    
    print('📍 PROVIDER: Loading persisted addresses for user: $userId');
    state = state.copyWith(isLoading: true, clearError: true);

    // Use last known/persisted address instead of API call
    // TODO: Get from SharedPreferences or secure storage
    final persistedAddress = CustomerAddress(
      id: 'persisted_001',
      userId: userId,
      formattedAddress: 'Last known pickup location', // This would come from local storage
      street: '',
      city: '',
      state: '',
      zipCode: '',
      country: 'US',
      isPrimary: true,
      addressType: 'pickup_location',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    
    print('📍 PROVIDER: Using persisted address: ${persistedAddress.formattedAddress}');
    
    state = state.copyWith(
      addresses: [persistedAddress],
      primaryAddress: persistedAddress,
      isLoading: false,
    );
  }

  /// Save a new address from PlaceDetails - stores locally
  Future<CustomerAddress?> saveAddressFromPlace({
    required String userId,
    required PlaceDetails placeDetails,
    bool isPrimary = true,
    String addressType = 'takeaway',
  }) async {
    print('📍 PROVIDER: Saving address from place details locally');
    print('📍 PROVIDER: Address: ${placeDetails.formattedAddress}');
    print('📍 PROVIDER: Is primary: $isPrimary');

    state = state.copyWith(clearError: true);

    try {
      // Create local address object
      final savedAddress = CustomerAddress(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
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

      print('📍 PROVIDER: Address saved locally: ${savedAddress.id}');
      
      // Update local state
      final updatedAddresses = [...state.addresses];
      final existingIndex = updatedAddresses.indexWhere((addr) => 
          addr.formattedAddress == savedAddress.formattedAddress);

      if (existingIndex >= 0) {
        updatedAddresses[existingIndex] = savedAddress;
      } else {
        updatedAddresses.add(savedAddress);
      }

      // Update primary address if this is primary
      CustomerAddress? primaryAddress = state.primaryAddress;
      if (savedAddress.isPrimary) {
        primaryAddress = savedAddress;
        // Mark other addresses as non-primary
        for (int i = 0; i < updatedAddresses.length; i++) {
          if (updatedAddresses[i].id != savedAddress.id) {
            updatedAddresses[i] = CustomerAddress(
              id: updatedAddresses[i].id,
              userId: updatedAddresses[i].userId,
              formattedAddress: updatedAddresses[i].formattedAddress,
              street: updatedAddresses[i].street,
              city: updatedAddresses[i].city,
              state: updatedAddresses[i].state,
              zipCode: updatedAddresses[i].zipCode,
              country: updatedAddresses[i].country,
              latitude: updatedAddresses[i].latitude,
              longitude: updatedAddresses[i].longitude,
              placeId: updatedAddresses[i].placeId,
              isPrimary: false,
              addressType: updatedAddresses[i].addressType,
              createdAt: updatedAddresses[i].createdAt,
              updatedAt: updatedAddresses[i].updatedAt,
            );
          }
        }
      }

      state = state.copyWith(
        addresses: updatedAddresses,
        primaryAddress: primaryAddress,
      );

      return savedAddress;
    } catch (e) {
      print('❌ PROVIDER: Error saving address: $e');
      state = state.copyWith(error: 'Failed to save address: $e');
      return null;
    }
  }

  /// Save address from manual input - stores locally
  Future<CustomerAddress?> saveAddress({
    required String userId,
    required String formattedAddress,
    String street = '',
    String city = '',
    String addressState = '',  // Renamed parameter to avoid conflict with 'state' property
    String zipCode = '',
    String country = 'US',
    double? latitude,
    double? longitude,
    String? placeId,
    bool isPrimary = true,
    String addressType = 'takeaway',
  }) async {
    print('📍 PROVIDER: Saving address from manual input locally: $formattedAddress');

    state = state.copyWith(clearError: true);

    try {
      // Create local address object
      final savedAddress = CustomerAddress(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        formattedAddress: formattedAddress,
        street: street,
        city: city,
        state: addressState,
        zipCode: zipCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
        placeId: placeId,
        isPrimary: isPrimary,
        addressType: addressType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update local state similar to saveAddressFromPlace
      final updatedAddresses = [...state.addresses];
      final existingIndex = updatedAddresses.indexWhere((addr) => 
          addr.formattedAddress == savedAddress.formattedAddress);

      if (existingIndex >= 0) {
        updatedAddresses[existingIndex] = savedAddress;
      } else {
        updatedAddresses.add(savedAddress);
      }

      CustomerAddress? primaryAddress = state.primaryAddress;
      if (savedAddress.isPrimary) {
        primaryAddress = savedAddress;
      }

      state = state.copyWith(
        addresses: updatedAddresses,
        primaryAddress: primaryAddress,
      );

      return savedAddress;
    } catch (e) {
      print('❌ PROVIDER: Error saving address: $e');
      state = state.copyWith(error: 'Failed to save address: $e');
      return null;
    }
  }

  /// Delete an address - local only
  Future<bool> deleteAddress(String userId, String addressId) async {
    print('📍 PROVIDER: Deleting address locally: $addressId');

    try {
      // Remove from local state
      final updatedAddresses = state.addresses.where((addr) => addr.id != addressId).toList();
      CustomerAddress? primaryAddress = state.primaryAddress;
      
      // Clear primary if it was deleted
      if (primaryAddress?.id == addressId) {
        primaryAddress = updatedAddresses.isNotEmpty ? updatedAddresses.first : null;
      }

      state = state.copyWith(
        addresses: updatedAddresses,
        primaryAddress: primaryAddress,
      );

      print('📍 PROVIDER: Address deleted locally');
      return true;
    } catch (e) {
      print('❌ PROVIDER: Error deleting address: $e');
      state = state.copyWith(error: 'Failed to delete address: $e');
      return false;
    }
  }

  /// Get primary address
  CustomerAddress? get primaryAddress => state.primaryAddress;

  /// Check if user has any saved addresses
  bool get hasAddresses => state.addresses.isNotEmpty;

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for customer addresses
final customerAddressProvider = StateNotifierProvider<CustomerAddressNotifier, CustomerAddressState>((ref) {
  return CustomerAddressNotifier();
});

/// Provider to get primary address for current user
final primaryAddressProvider = Provider<CustomerAddress?>((ref) {
  final addressState = ref.watch(customerAddressProvider);
  return addressState.primaryAddress;
});

/// Provider to check if user has saved addresses
final hasAddressesProvider = Provider<bool>((ref) {
  final addressState = ref.watch(customerAddressProvider);
  return addressState.addresses.isNotEmpty;
});