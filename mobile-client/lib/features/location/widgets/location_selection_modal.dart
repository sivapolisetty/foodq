import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../providers/location_provider.dart';
import '../providers/location_preferences_provider.dart';
import '../providers/customer_address_provider.dart';
import '../../../core/widgets/custom_address_autocomplete_field.dart';
import '../../../core/services/address_service.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class LocationSelectionModal extends ConsumerStatefulWidget {
  final Function(String address, double? lat, double? lng)? onLocationSelected;
  
  const LocationSelectionModal({
    Key? key,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  ConsumerState<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends ConsumerState<LocationSelectionModal> {
  final TextEditingController _addressController = TextEditingController();
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  PlaceDetails? _selectedPlaceDetails; // Store full place details
  bool _isLoadingCurrentLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    print('🎯 MODAL: ===== _useCurrentLocation() button pressed =====');
    print('🎯 MODAL: Setting loading state to true...');
    
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      print('🎯 MODAL: Calling locationProvider.notifier.getCurrentLocation()...');
      await ref.read(locationProvider.notifier).getCurrentLocation();
      print('🎯 MODAL: getCurrentLocation() call completed, reading location state...');
      
      final locationState = ref.read(locationProvider);
      print('🎯 MODAL: Location state - position: ${locationState.position?.toString() ?? 'NULL'}');
      print('🎯 MODAL: Location state - address: ${locationState.address?.formattedAddress ?? 'NULL'}');
      print('🎯 MODAL: Location state - error: ${locationState.error ?? 'NULL'}');
      print('🎯 MODAL: Location state - isLoading: ${locationState.isLoading}');
      
      if (locationState.position != null && locationState.address != null) {
        print('🎯 MODAL: Both position and address available - processing...');
        final address = locationState.address!;
        final position = locationState.position!;
        
        print('🎯 MODAL: Setting selected address: ${address.formattedAddress}');
        setState(() {
          _selectedAddress = address.formattedAddress;
          _selectedLat = position.latitude;
          _selectedLng = position.longitude;
          _addressController.text = address.formattedAddress;
        });
        
        print('🎯 MODAL: Automatically calling _setLocation()...');
        // Automatically set location and close modal
        _setLocation();
      } else if (locationState.error != null) {
        print('❌ MODAL: Location error - showing snackbar: ${locationState.error}');
        
        // Provide platform-specific error messages
        String errorMessage = locationState.error!;
        if (kIsWeb) {
          if (errorMessage.contains('permission')) {
            errorMessage = 'Location access is required.\n\n'
                          'On iPhone Safari:\n'
                          '• Tap the location icon (🌐) in the address bar\n'
                          '• Select "Allow" for location access\n'
                          '• Or go to Settings → Safari → Location\n\n'
                          'Then try again or enter your address manually.';
          } else if (errorMessage.contains('timeout') || errorMessage.contains('TimeoutException')) {
            errorMessage = 'Location detection timed out.\n\n'
                          'Please ensure:\n'
                          '• Location Services are enabled in Settings\n'
                          '• You have a good GPS signal\n'
                          '• Safari has location permission\n\n'
                          'Try again or enter your address manually.';
          } else if (errorMessage.contains('unavailable')) {
            errorMessage = 'Location services are not available.\n\n'
                          'Please check:\n'
                          '• Location Services are enabled in iPhone Settings\n'
                          '• Safari has permission to use location\n'
                          '• You\'re not in airplane mode\n\n'
                          'Or enter your address manually below.';
          } else {
            errorMessage = 'Unable to detect your location automatically.\n\n'
                          'This can happen due to:\n'
                          '• Browser privacy settings\n'
                          '• Weak GPS signal\n'
                          '• Location services disabled\n\n'
                          'Please enter your address manually below.';
          }
        }
        
        _showLocationErrorDialog(errorMessage);
      } else {
        print('⚠️ MODAL: No position/address and no error - unexpected state');
        print('⚠️ MODAL: Position null: ${locationState.position == null}');
        print('⚠️ MODAL: Address null: ${locationState.address == null}');
        
        String message = 'Location detection incomplete. Please try again or enter your address manually.';
        if (kIsWeb) {
          message = 'Location detection failed. This may be due to browser security restrictions. Please try entering your address manually.';
        }
        _showErrorSnackBar(message);
      }
    } catch (e, stackTrace) {
      print('❌ MODAL: Exception in _useCurrentLocation(): $e');
      print('📚 MODAL: Stack trace: $stackTrace');
      _showErrorSnackBar('Failed to get current location: $e');
    } finally {
      print('🎯 MODAL: Setting loading state to false...');
      setState(() {
        _isLoadingCurrentLocation = false;
      });
      print('🎯 MODAL: ===== _useCurrentLocation() completed =====');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLocationErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Location Not Available'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can still search for your address using the field above.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Immediately try location again
              _useCurrentLocation();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Focus on the address input field
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: const Text('Enter Address'),
          ),
        ],
      ),
    );
  }

  void _setLocation() async {
    if (_selectedAddress != null) {
      print('🎯 MODAL: Setting location: $_selectedAddress');
      
      // Save to location provider
      ref.read(locationProvider.notifier).setManualAddress(
        _selectedAddress!,
        _selectedLat,
        _selectedLng,
      );
      
      // Save to location preferences for persistence
      ref.read(locationPreferencesProvider.notifier).updateLastKnownLocation(
        address: _selectedAddress!,
        latitude: _selectedLat,
        longitude: _selectedLng,
      );

      // Save to database if user is authenticated
      await _saveAddressToDatabase();
      
      // Callback to parent
      widget.onLocationSelected?.call(_selectedAddress!, _selectedLat, _selectedLng);
      
      // Close modal
      if (context.canPop()) {
        context.pop();
      } else if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      _showErrorSnackBar('Please select an address first');
    }
  }

  Future<void> _saveAddressToDatabase() async {
    try {
      final currentUser = ref.read(authenticatedUserProvider).value;
      if (currentUser == null) {
        print('🎯 MODAL: No authenticated user, skipping database save');
        return;
      }

      print('🎯 MODAL: Saving address to database for user: ${currentUser.id}');

      // If we have full place details, use them
      if (_selectedPlaceDetails != null) {
        print('🎯 MODAL: Saving full place details to database');
        final savedAddress = await ref.read(customerAddressProvider.notifier)
            .saveAddressFromPlace(
          userId: currentUser.id,
          placeDetails: _selectedPlaceDetails!,
          isPrimary: true, // Make it the primary address
          addressType: 'takeaway',
        );

        if (savedAddress != null) {
          print('✅ MODAL: Address with full details saved to database: ${savedAddress.id}');
        } else {
          print('❌ MODAL: Failed to save address to database');
        }
      } else if (_selectedLat != null && _selectedLng != null) {
        // Create a basic PlaceDetails object with coordinates
        print('🎯 MODAL: Saving address with coordinates to database');
        final placeDetails = PlaceDetails(
          formattedAddress: _selectedAddress!,
          street: '',
          city: '',
          state: '',
          zipCode: '',
          country: 'US', // Default
          latitude: _selectedLat,
          longitude: _selectedLng,
          placeId: '',
        );

        final savedAddress = await ref.read(customerAddressProvider.notifier)
            .saveAddressFromPlace(
          userId: currentUser.id,
          placeDetails: placeDetails,
          isPrimary: true,
          addressType: 'takeaway',
        );

        if (savedAddress != null) {
          print('✅ MODAL: Address with coordinates saved to database: ${savedAddress.id}');
        } else {
          print('❌ MODAL: Failed to save address to database');
        }
      } else {
        // Save just the formatted address without coordinates
        final savedAddress = await ref.read(customerAddressProvider.notifier)
            .saveAddress(
          userId: currentUser.id,
          formattedAddress: _selectedAddress!,
          isPrimary: true,
          addressType: 'takeaway',
        );

        if (savedAddress != null) {
          print('✅ MODAL: Address saved to database successfully: ${savedAddress.id}');
        } else {
          print('❌ MODAL: Failed to save address to database');
        }
      }
    } catch (e) {
      print('❌ MODAL: Error saving address to database: $e');
      // Don't show error to user as this is a background operation
      // The address is still saved locally and in preferences
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In what area do you want to find food for takeaway? Enter an address or use your current location to find restaurants nearby.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Address search field
                CustomAddressAutocompleteField(
                  controller: _addressController,
                  hintText: 'Search address',
                  prefixIcon: Icons.search,
                  onPlaceSelected: (place) {
                    print('🎯 MODAL: Place selected from dropdown: ${place.formattedAddress}');
                    print('🎯 MODAL: Place coordinates: ${place.latitude}, ${place.longitude}');
                    print('🎯 MODAL: Place details - City: ${place.city}, State: ${place.state}, ZIP: ${place.zipCode}');
                    setState(() {
                      _selectedAddress = place.formattedAddress;
                      _selectedLat = place.latitude;
                      _selectedLng = place.longitude;
                      _selectedPlaceDetails = place; // Store full place details
                    });
                    print('🎯 MODAL: Selected address updated, button should now be enabled: $_selectedAddress');
                  },
                  onAddressSelected: (address) {
                    // Fallback callback if onPlaceSelected fails
                    print('🎯 MODAL: Address selected (fallback): $address');
                    setState(() {
                      _selectedAddress = address;
                      _selectedLat = null;  // No coordinates available
                      _selectedLng = null;
                      _selectedPlaceDetails = null; // No place details available
                    });
                    print('🎯 MODAL: Selected address updated via fallback, button should now be enabled: $_selectedAddress');
                  },
                  onChanged: (value) {
                    print('🎯 MODAL: Address field changed to: "$value"');
                    // Clear selection if user manually types
                    if (value != _selectedAddress) {
                      print('🎯 MODAL: Clearing selection because typed value differs from selected');
                      setState(() {
                        _selectedAddress = null;
                        _selectedLat = null;
                        _selectedLng = null;
                        _selectedPlaceDetails = null;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // OR divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
          ),
          
          // Use current location button
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isLoadingCurrentLocation ? null : _useCurrentLocation,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoadingCurrentLocation
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Use your current location',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                // iOS Safari location hint
                if (kIsWeb) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'On iPhone: Allow location access when prompted, or tap 🌐 in address bar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Show retry button if location permission was denied
                Consumer(
                  builder: (context, ref, child) {
                    final locationState = ref.watch(locationProvider);
                    if (locationState.error != null && 
                        locationState.error!.toLowerCase().contains('permission')) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingCurrentLocation ? null : () async {
                                // Clear the error first
                                ref.read(locationProvider.notifier).clearLocation();
                                // Try location again
                                await _useCurrentLocation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text(
                                'Retry Location Permission',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Debug info (remove in production)
          if (kDebugMode) 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEBUG: Selected address = "${_selectedAddress ?? 'NULL'}"',
                  style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                ),
              ),
            ),
          
          if (kDebugMode) const SizedBox(height: 12),
          
          // Set location button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedAddress != null ? _setLocation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Set location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedAddress != null ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}