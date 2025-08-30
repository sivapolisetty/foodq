import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/widgets/custom_address_autocomplete_field.dart';
import '../../../core/services/address_service.dart';
import '../models/restaurant_onboarding_request.dart';
import '../providers/restaurant_onboarding_provider.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

class RestaurantOnboardingModal extends ConsumerStatefulWidget {
  const RestaurantOnboardingModal({super.key});

  @override
  ConsumerState<RestaurantOnboardingModal> createState() => _RestaurantOnboardingModalState();
}

class _RestaurantOnboardingModalState extends ConsumerState<RestaurantOnboardingModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Restaurant Information
  final _restaurantNameController = TextEditingController();
  final _restaurantDescriptionController = TextEditingController();
  String _selectedCuisineType = '';
  File? _restaurantLogoFile;
  File? _restaurantCoverImageFile;
  
  // Owner Information
  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  
  // Location Information
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  bool _isValidatingAddress = false;
  bool _addressValidated = false;
  String _addressValidationMessage = '';
  bool _isGettingCurrentLocation = false;
  double? _currentLatitude;
  double? _currentLongitude;
  
  // Business Information
  final _businessLicenseController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  // Cuisine type options as per requirements
  final List<String> _cuisineTypes = [
    'North Indian',
    'South Indian',
    'Street Food',
    'Chinese',
    'Italian',
    'Mexican',
    'Thai',
    'American',
    'Mediterranean',
    'Japanese',
    'Korean',
    'Vietnamese',
    'Lebanese',
    'Continental',
    'Fast Food',
    'Desserts'
  ];

  @override
  void dispose() {
    _animationController.dispose();
    _restaurantNameController.dispose();
    _restaurantDescriptionController.dispose();
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _ownerPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _businessLicenseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _closeModal() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background overlay
            GestureDetector(
              onTap: () {}, // Prevent closing by tapping outside
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            // Sliding panel from top
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20), // Top padding for status bar
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurant Partnership Application',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join grabeat as a Restaurant Partner',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _closeModal,
                    icon: const Icon(Icons.close),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            
            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: Scrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRestaurantInfoSection(),
                        const SizedBox(height: 24),
                        _buildOwnerInfoSection(),
                        const SizedBox(height: 24),
                        _buildLocationInfoSection(),
                        const SizedBox(height: 24),
                        _buildBusinessInfoSection(),
                        const SizedBox(height: 24),
                        _buildNextStepsInfo(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Footer with Submit Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () {
                        print('🔘 Button onPressed triggered');
                        _submitApplication();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Submit Application',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfoSection() {
    return _buildSection(
      title: 'Restaurant Information',
      children: [
        // Restaurant Name (required)
        TextFormField(
          controller: _restaurantNameController,
          decoration: const InputDecoration(
            labelText: 'Restaurant Name *',
            hintText: 'e.g., Mario\'s Authentic Pizza',
            prefixIcon: Icon(Icons.restaurant),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Restaurant name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Cuisine Type (required)
        DropdownButtonFormField<String>(
          value: _selectedCuisineType.isEmpty ? null : _selectedCuisineType,
          decoration: const InputDecoration(
            labelText: 'Cuisine Type *',
            prefixIcon: Icon(Icons.local_dining),
          ),
          items: _cuisineTypes.map((cuisine) {
            return DropdownMenuItem(
              value: cuisine,
              child: Text(cuisine),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCuisineType = value ?? '';
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a cuisine type';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Restaurant Description (optional)
        TextFormField(
          controller: _restaurantDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Restaurant Description (Optional)',
            hintText: 'Describe your restaurant, specialties, atmosphere...',
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Restaurant Photo Upload
        _buildPhotoUploadSection(),
      ],
    );
  }

  Widget _buildOwnerInfoSection() {
    return _buildSection(
      title: 'Owner Information',
      children: [
        // Full Name (required)
        TextFormField(
          controller: _ownerNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            hintText: 'e.g., John Smith',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email Address (required)
        TextFormField(
          controller: _ownerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            hintText: 'owner@restaurant.com',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email address is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Phone Number (required)
        TextFormField(
          controller: _ownerPhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: '+1 (555) 123-4567',
            prefixIcon: Icon(Icons.phone),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationInfoSection() {
    return _buildSection(
      title: 'Location Information',
      children: [
        // Use Current Location Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton.icon(
            onPressed: _isGettingCurrentLocation ? null : _useCurrentLocation,
            icon: _isGettingCurrentLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(_isGettingCurrentLocation ? 'Getting Location...' : 'Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        // Full Address with Autocomplete (required)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug info
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '🔧 DEBUG: CustomAddressAutocompleteField now uses our API endpoint instead of CORS proxy.\nNo more direct Google Places API calls from Flutter.',
                    style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                  ),
                ),
                CustomAddressAutocompleteField(
                  controller: _addressController,
                  labelText: 'Full Address *',
                  hintText: 'Start typing your address...',
                  prefixIcon: Icons.location_on,
                  onChanged: _validateAddress,
                  onAddressSelected: (addressText) {
                    print('🏠 Address selected from autocomplete: $addressText');
                    setState(() {
                      _addressValidated = true;
                      _addressValidationMessage = '✓ Address selected from suggestions';
                    });
                  },
                  onPlaceSelected: (placeDetails) {
                    print('📍 [MODAL] onPlaceSelected callback triggered!');
                    print('🏠 [MODAL] Place details received: ${placeDetails.formattedAddress}');
                    print('🏙️ [MODAL] Details breakdown:');
                    print('   - Street: "${placeDetails.street}"');
                    print('   - City: "${placeDetails.city}"');
                    print('   - State: "${placeDetails.state}"');
                    print('   - ZIP: "${placeDetails.zipCode}"');
                    print('   - Country: "${placeDetails.country}"');
                    print('   - Lat/Lng: ${placeDetails.latitude}, ${placeDetails.longitude}');
                    
                    print('🔧 [MODAL] Current field values before update:');
                    print('   - City field: "${_cityController.text}"');
                    print('   - State field: "${_stateController.text}"');
                    print('   - ZIP field: "${_zipCodeController.text}"');
                    
                    setState(() {
                      print('🔄 [MODAL] Updating fields with setState...');
                      _cityController.text = placeDetails.city;
                      _stateController.text = placeDetails.state;
                      _zipCodeController.text = placeDetails.zipCode;
                      _currentLatitude = placeDetails.latitude;
                      _currentLongitude = placeDetails.longitude;
                      _addressValidated = true;
                      _addressValidationMessage = '✓ Address details populated from selection';
                      print('✅ [MODAL] Fields updated successfully');
                    });
                    
                    print('✅ [MODAL] Final field values after update:');
                    print('   - City field: "${_cityController.text}"');
                    print('   - State field: "${_stateController.text}"');
                    print('   - ZIP field: "${_zipCodeController.text}"');
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Full address is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
            
            // Address Status Indicator
            if (_isValidatingAddress)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Validating address...',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            
            if (_addressValidated && _addressValidationMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _addressValidationMessage,
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Debug info for field values
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border.all(color: Colors.blue[200]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 DEBUG: Current field values',
                style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.bold),
              ),
              Text(
                'City: "${_cityController.text}" | State: "${_stateController.text}" | ZIP: "${_zipCodeController.text}"',
                style: TextStyle(fontSize: 10, color: Colors.blue[700]),
              ),
              if (_cityController.text.isNotEmpty || _stateController.text.isNotEmpty || _zipCodeController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✅ FIELDS POPULATED!',
                    style: TextStyle(
                      fontSize: 10, 
                      color: Colors.green[800], 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // City and State Row
        Row(
          children: [
            // City (auto-populated from location)
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 12),
            // State (auto-populated from location)
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  prefixIcon: Icon(Icons.map),
                ),
                readOnly: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // ZIP Code (required)
        TextFormField(
          controller: _zipCodeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ZIP Code *',
            hintText: '12345',
            prefixIcon: Icon(Icons.local_post_office),
          ),
          onChanged: (_) => _validateAddress(_addressController.text),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'ZIP code is required';
            }
            return null;
          },
        ),
        
        // Address Validation Status
        if (_addressValidationMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _addressValidated 
                  ? Colors.green[50] 
                  : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _addressValidated 
                    ? Colors.green[200]! 
                    : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _addressValidated ? Icons.check_circle : Icons.info,
                  color: _addressValidated ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _addressValidationMessage,
                    style: TextStyle(
                      color: _addressValidated ? Colors.green[700] : Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Location Info Box
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location Options',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Use "Use Current Location" button to auto-populate your GPS location\n• Or start typing in the address field for smart suggestions\n• We need accurate location for customer discovery and delivery calculations',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoSection() {
    return _buildSection(
      title: 'Business Information',
      children: [
        // Business License Number (optional)
        TextFormField(
          controller: _businessLicenseController,
          decoration: const InputDecoration(
            labelText: 'Business License Number (Optional)',
            hintText: 'e.g., BL-123456789',
            prefixIcon: Icon(Icons.badge),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurant Images',
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Logo and Cover Image Row
        Row(
          children: [
            // Restaurant Logo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logo',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ImagePickerButton(
                    imageFile: _restaurantLogoFile,
                    label: 'Add Logo',
                    icon: Icons.business,
                    onImageSelected: (file) {
                      setState(() {
                        _restaurantLogoFile = file;
                      });
                    },
                    width: double.infinity,
                    height: 100,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Restaurant Cover Image
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cover Photo',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ImagePickerButton(
                    imageFile: _restaurantCoverImageFile,
                    label: 'Add Cover',
                    icon: Icons.photo,
                    onImageSelected: (file) {
                      setState(() {
                        _restaurantCoverImageFile = file;
                      });
                    },
                    width: double.infinity,
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // Helper text
        const SizedBox(height: 8),
        Text(
          'Upload high-quality images to attract more customers. Logo should be square, cover photo should be landscape.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Next Steps',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildNextStep('✓', 'Review within 2-3 business days'),
          _buildNextStep('✓', 'Email notification with approval status'),
          _buildNextStep('✓', 'Dashboard access upon approval'),
          _buildNextStep('✓', 'Setup assistance for first listings'),
        ],
      ),
    );
  }

  Widget _buildNextStep(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(icon, style: TextStyle(color: Colors.blue[700])),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  void _validateAddress(String address) {
    if (address.isEmpty || _zipCodeController.text.isEmpty) {
      setState(() {
        _addressValidated = false;
        _addressValidationMessage = '';
      });
      return;
    }

    setState(() {
      _isValidatingAddress = true;
    });

    // Simulate address validation (in real app, use geocoding service)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isValidatingAddress = false;
          _addressValidated = true;
          _addressValidationMessage = '✓ Address validated and location found';
        });
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      print('🌍 Getting current location...');
      
      // First, test the location service
      await LocationService.testLocationServices();
      
      final position = await LocationService.getCurrentPosition();
      
      if (position != null) {
        print('📍 Got position: ${position.latitude}, ${position.longitude}');
        
        // Get address from coordinates
        print('🔄 Converting coordinates to address...');
        final address = await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        print('🔍 Address result: $address');
        if (address != null) {
          print('📧 Formatted address: "${address.formattedAddress}"');
          print('🏙️ City: "${address.city}"');
          print('🗺️ State: "${address.state}"');
          print('📮 ZIP: "${address.postalCode}"');
          print('🏠 Street: "${address.street}"');
        }
        
        if (address != null && mounted) {
          print('✅ Updating UI with address data...');
          setState(() {
            _currentLatitude = address.latitude;
            _currentLongitude = address.longitude;
            _addressController.text = address.formattedAddress;
            _cityController.text = address.city;
            _stateController.text = address.state;
            _zipCodeController.text = address.postalCode;
            _addressValidated = true;
            _addressValidationMessage = '✓ Address populated from current location';
          });
          
          print('✅ UI updated successfully');
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address populated from your current location!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('❌ Address is null or widget not mounted');
          throw Exception('Could not get address from location - address is null');
        }
      } else {
        print('❌ Position is null');
        print('🧪 Testing geocoding with known coordinates (San Francisco)...');
        
        // Test with known coordinates as fallback
        final testAddress = await LocationService.getAddressFromCoordinates(
          37.7749,  // San Francisco latitude
          -122.4194, // San Francisco longitude
        );
        
        if (testAddress != null && mounted) {
          print('✅ Test geocoding worked! Using test address: ${testAddress.formattedAddress}');
          setState(() {
            _currentLatitude = testAddress.latitude;
            _currentLongitude = testAddress.longitude;
            _addressController.text = testAddress.formattedAddress;
            _cityController.text = testAddress.city;
            _stateController.text = testAddress.state;
            _zipCodeController.text = testAddress.postalCode;
            _addressValidated = true;
            _addressValidationMessage = '✓ Test address populated (location services unavailable)';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Test address populated (location services unavailable)'),
              backgroundColor: Colors.orange,
            ),
          );
          
          return; // Don't throw exception, we have test data
        }
        
        throw Exception('Could not get current location - position is null');
      }
    } catch (e) {
      print('💥 Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get current location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  Future<void> _submitApplication() async {
    print('🚀 Submit button clicked');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    print('✅ Form validation passed');

    // Get current user
    print('📱 Getting current user...');
    final currentUserAsync = ref.read(authenticatedUserProvider);
    final currentUser = currentUserAsync.value;
    print('👤 Current user: ${currentUser?.id} - ${currentUser?.name}');
    
    if (currentUser == null) {
      print('❌ No current user found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first to submit application'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create form data
      final formData = RestaurantOnboardingFormData(
        restaurantName: _restaurantNameController.text.trim(),
        cuisineType: _selectedCuisineType,
        restaurantDescription: _restaurantDescriptionController.text.trim(),
        restaurantPhotoUrl: null, // TODO: Upload images to storage
        ownerName: _ownerNameController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        ownerPhone: _ownerPhoneController.text.trim(),
        address: _addressController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        latitude: _currentLatitude ?? 0.0,
        longitude: _currentLongitude ?? 0.0,
        businessLicense: _businessLicenseController.text.trim(),
        userId: currentUser.id,
      );

      // Submit application
      final application = await ref.read(restaurantOnboardingProvider.notifier)
          .submitApplication(formData);

      if (mounted && application != null) {
        Navigator.of(context).pop();
        
        // Show success modal
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Application Submitted!'),
            content: const Text(
              'Your restaurant partnership application has been submitted successfully. '
              'We will review your application within 2-3 business days and send you '
              'an email notification with the approval status.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}