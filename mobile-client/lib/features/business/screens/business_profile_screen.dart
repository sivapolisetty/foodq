import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../../core/widgets/custom_address_autocomplete_field.dart';
import '../../../core/services/address_service.dart';
import '../../location/providers/location_provider.dart';
import '../../../core/services/location_service.dart';
import '../services/business_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../../../shared/models/business.dart';

/// Business profile screen for updating restaurant information
/// Allows business owners to edit their business details, hours, and settings
class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  // Form controllers
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  
  // Location data
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  bool _addressValidated = false;
  
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBusinessData() async {
    // Use a post-frame callback to ensure the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUserAsync = ref.read(authenticatedUserProvider);
      await currentUserAsync.when(
        data: (user) async {
          if (user != null && user.isBusiness && user.businessId != null) {
            print('🔍 Business Profile Debug - User Data:');
            print('   ID: ${user.id}');
            print('   Name: ${user.name}');
            print('   Email: ${user.email}');
            print('   Business ID: ${user.businessId}');
            print('   Business Name: ${user.businessName}');
            print('   Address: ${user.address}');
            print('   Phone: ${user.phone}');
            
            // Load complete business data from API since user object might be incomplete
            try {
              final businessService = BusinessService();
              print('🔍 Loading complete business data from API for business ID: ${user.businessId}');
              
              // Get business data directly by business ID (not owner ID)
              final businessData = await _getBusinessById(user.businessId!);
              
              if (businessData != null) {
                print('🔍 Complete Business Data Loaded:');
                print('   Business Name: ${businessData.name}');
                print('   Description: ${businessData.description}');
                print('   Address: ${businessData.address}');
                print('   Phone: ${businessData.phone}');
                print('   Email: ${businessData.email}');
                print('   Website: ${businessData.website}');
                print('   Latitude: ${businessData.latitude}');
                print('   Longitude: ${businessData.longitude}');
                
                if (mounted) {
                  setState(() {
                    _businessNameController.text = businessData.name;
                    _descriptionController.text = businessData.description ?? '';
                    _addressController.text = businessData.address;
                    _cityController.text = businessData.city ?? '';
                    _stateController.text = businessData.state ?? '';
                    _zipCodeController.text = businessData.zipCode ?? '';
                    _phoneController.text = businessData.phone ?? '';
                    _emailController.text = businessData.email ?? '';
                    _websiteController.text = businessData.website ?? '';
                    
                    // Set location data if available
                    if (businessData.latitude != null && businessData.longitude != null) {
                      _selectedLat = businessData.latitude;
                      _selectedLng = businessData.longitude;
                      _selectedAddress = businessData.address;
                      _addressValidated = true;
                    }
                  });
                }
              } else {
                print('⚠️ No business data found for owner ID: ${user.id}');
                // Fall back to user data
                _populateFromUserData(user);
              }
            } catch (e) {
              print('💥 Error loading business data: $e');
              // Fall back to user data
              _populateFromUserData(user);
            }
          } else {
            print('🔍 Business Profile Debug - User is null or not business: $user');
          }
        },
        loading: () {},
        error: (error, stack) {
          print('💥 Error loading user data: $error');
        },
      );
    });
  }
  
  void _populateFromUserData(AppUser user) {
    if (mounted) {
      setState(() {
        _businessNameController.text = user.businessName ?? user.name;
        _descriptionController.text = ''; // Not available in user object
        _addressController.text = user.address ?? '';
        _phoneController.text = user.phone ?? '';
        _emailController.text = user.email;
        _websiteController.text = ''; // Not available in user object
      });
    }
  }

  // Helper method to dismiss keyboard
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // Helper method to get business data by business ID using the correct API endpoint
  Future<Business?> _getBusinessById(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/businesses/$businessId'),
        headers: ApiConfig.headers,
      );

      print('🔍 Get business by ID response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          return Business.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('💥 Error getting business by ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null || !currentUser.isBusiness) {
          return _buildUnauthorizedScreen();
        }
        
        // Update form fields when user data changes (only if different)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateFormFields(currentUser);
          }
        });
        
        return _buildBusinessProfileScreen(currentUser);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, _) => _buildErrorScreen(error),
      ),
    );
  }
  
  void _updateFormFields(AppUser user) {
    // Debug: Print user data to console
    print('🔍 Business Profile Debug - User Data:');
    print('   ID: ${user.id}');
    print('   Name: ${user.name}');
    print('   Email: ${user.email}');
    print('   Business ID: ${user.businessId}');
    print('   Business Name: ${user.businessName}');
    print('   Address: ${user.address}');
    print('   Phone: ${user.phone}');
    print('   User Type: ${user.userType}');
    print('   Is Business: ${user.isBusiness}');
    
    // Only update if the current text is empty or different
    if (_businessNameController.text.isEmpty) {
      _businessNameController.text = user.businessName ?? user.name;
    }
    if (_addressController.text.isEmpty) {
      _addressController.text = user.address ?? '';
    }
    if (_phoneController.text.isEmpty) {
      _phoneController.text = user.phone ?? '';
    }
    if (_emailController.text.isEmpty) {
      _emailController.text = user.email;
    }
  }

  Widget _buildBusinessProfileScreen(AppUser businessUser) {
    return OverflowSafeWrapper(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(
            'Business Profile',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.onSurface),
          actions: [
            // Add keyboard dismiss button for iOS
            IconButton(
              icon: Icon(Icons.keyboard_hide),
              onPressed: _dismissKeyboard,
              tooltip: 'Hide keyboard',
            ),
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Save',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          onChanged: () => setState(() => _hasUnsavedChanges = true),
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildBusinessInfoSection(),
                const SizedBox(height: 32),
                _buildContactSection(),
                const SizedBox(height: 32),
                _buildLocationSection(),
                const SizedBox(height: 32),
                _buildBusinessHoursSection(),
                const SizedBox(height: 32),
                _buildServiceOptionsSection(),
                const SizedBox(height: 32),
                _buildDangerZoneSection(),
                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  Widget _buildBusinessInfoSection() {
    return _buildSection(
      title: 'Business Information',
      icon: Icons.business,
      children: [
        TextFormField(
          controller: _businessNameController,
          decoration: InputDecoration(
            labelText: 'Business Name *',
            hintText: 'Enter your business name',
            prefixIcon: const Icon(Icons.store),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Tell customers about your business...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _websiteController,
          decoration: InputDecoration(
            labelText: 'Website',
            hintText: 'https://yourwebsite.com',
            prefixIcon: const Icon(Icons.language),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Contact Information',
      icon: Icons.contact_phone,
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number *',
            hintText: '(555) 123-4567',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Business Email *',
            hintText: 'business@example.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@')) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: '📍 Location',
      icon: Icons.location_on,
      children: [
        // Address autocomplete field
        CustomAddressAutocompleteField(
          controller: _addressController,
          labelText: 'Business Address *',
          hintText: 'Start typing your business address...',
          prefixIcon: Icons.location_on,
          onPlaceSelected: (place) {
            print('🏢 Business Profile - Place selected: ${place.formattedAddress}');
            print('🏢 Business Profile - Place details:');
            print('   Street: "${place.street}"');
            print('   City: "${place.city}"');
            print('   State: "${place.state}"');
            print('   ZIP Code: "${place.zipCode}"');
            print('   Country: "${place.country}"');
            print('   Latitude: ${place.latitude}');
            print('   Longitude: ${place.longitude}');
            
            setState(() {
              _selectedAddress = place.formattedAddress;
              _selectedLat = place.latitude;
              _selectedLng = place.longitude;
              _addressValidated = true;
              
              // Auto-populate city, state, zip from place details
              _cityController.text = place.city;
              _stateController.text = place.state;
              _zipCodeController.text = place.zipCode;
              
              print('🏢 Business Profile - Controllers updated:');
              print('   City Controller: "${_cityController.text}"');
              print('   State Controller: "${_stateController.text}"');
              print('   ZIP Controller: "${_zipCodeController.text}"');
            });
          },
          onAddressSelected: (address) {
            print('🏢 Business Profile - Address selected (fallback): $address');
            setState(() {
              _selectedAddress = address;
              _addressValidated = false; // No coordinates available
            });
          },
          onChanged: (value) {
            // Clear validation if user manually types
            if (value != _selectedAddress) {
              setState(() {
                _selectedAddress = null;
                _selectedLat = null;
                _selectedLng = null;
                _addressValidated = false;
                _cityController.clear();
                _stateController.clear();
                _zipCodeController.clear();
              });
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // OR divider
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.onSurfaceVariant.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.onSurfaceVariant.withOpacity(0.3))),
          ],
        ),
        const SizedBox(height: 16),
        
        // Use Current Location button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoadingCurrentLocation 
                ? null 
                : () => _useCurrentLocation(),
            icon: _isLoadingCurrentLocation 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary.withOpacity(0.6),
                      ),
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isLoadingCurrentLocation 
                  ? 'Getting location...' 
                  : 'Use Current Location',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Info text - Enhanced with current location feature
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search for your address above or use current location.',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // City, State, ZIP row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City *',
                  hintText: 'City',
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'City is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State *',
                  hintText: 'State',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'State is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _zipCodeController,
                decoration: InputDecoration(
                  labelText: 'ZIP *',
                  hintText: '12345',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ZIP is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Address validation status
        if (_addressValidated) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Address verified and coordinates saved',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Admin approval warning
        if (_hasUnsavedChanges) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warningContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Approval Required',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.onWarningContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Changes to business information require admin approval before they become visible to customers.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onWarningContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Info about location importance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your address helps customers find you and is used for delivery zones. Use the search above to ensure accurate location data.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onInfoContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessHoursSection() {
    return _buildSection(
      title: 'Business Hours',
      icon: Icons.access_time,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Operating Hours',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Business hours configuration coming soon!\nCurrently showing as open 24/7.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceOptionsSection() {
    return _buildSection(
      title: 'Service Options',
      icon: Icons.delivery_dining,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.settings,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Service Settings',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Payment options, delivery settings, and service preferences will be available here.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return _buildSection(
      title: 'Account Settings',
      icon: Icons.warning,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Danger Zone',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Account deactivation and data management options.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onErrorContainer,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showDeactivateAccountDialog(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                ),
                child: const Text('Deactivate Account'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(authenticatedUserProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthorizedScreen() {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Business Access Required',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You need to be logged in as a business user to access this page.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/business-home'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    return currentUserAsync.when(
      data: (currentUser) => CustomBottomNav(
        currentIndex: 4, // Profile index
        currentUser: currentUser,
        onTap: (index) => _handleBottomNavTap(index),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/business-home');
        break;
      case 1:
        context.go('/deals');
        break;
      case 2:
        context.go('/qr-scanner');
        break;
      case 3:
        context.go('/orders');
        break;
      case 4:
        // Already on profile
        break;
    }
  }

  Future<void> _useCurrentLocation() async {
    print('🏢 BUSINESS PROFILE: Using current location for business address');
    
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      print('🏢 BUSINESS PROFILE: Getting current location...');
      await ref.read(locationProvider.notifier).getCurrentLocation();
      
      final locationState = ref.read(locationProvider);
      print('🏢 BUSINESS PROFILE: Location state - position: ${locationState.position?.toString() ?? 'NULL'}');
      print('🏢 BUSINESS PROFILE: Location state - address: ${locationState.address?.formattedAddress ?? 'NULL'}');
      
      if (locationState.position != null && locationState.address != null) {
        print('🏢 BUSINESS PROFILE: Got location and address - updating form');
        final address = locationState.address!;
        final position = locationState.position!;
        
        setState(() {
          _selectedAddress = address.formattedAddress;
          _selectedLat = position.latitude;
          _selectedLng = position.longitude;
          _addressController.text = address.formattedAddress;
          _addressValidated = true;
          
          // Auto-populate other fields if available
          _cityController.text = address.locality ?? '';
          _stateController.text = address.administrativeArea ?? '';
          _zipCodeController.text = address.postalCode ?? '';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Current location set as business address'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (locationState.error != null) {
        print('🏢 BUSINESS PROFILE: Location error: ${locationState.error}');
        _showLocationErrorDialog(locationState.error!);
      } else {
        print('🏢 BUSINESS PROFILE: No location data available');
        _showLocationErrorDialog('Unable to get current location. Please try again or enter address manually.');
      }
    } catch (e) {
      print('🏢 BUSINESS PROFILE: Exception getting location: $e');
      _showLocationErrorDialog('Failed to get current location: $e');
    } finally {
      setState(() {
        _isLoadingCurrentLocation = false;
      });
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
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Try location again
              _useCurrentLocation();
            },
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
      _scrollController.animateTo(0, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut);
      return;
    }

    // Save changes directly without admin approval

    setState(() => _isLoading = true);

    try {
      // Get current user
      final currentUser = ref.read(authenticatedUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Prepare update data - only fields that exist in the businesses table
      final updateData = {
        'name': _businessNameController.text.trim(),  // Use 'name' instead of 'business_name'
        'description': _descriptionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'website': _websiteController.text.trim(),
        // Location data
        'address': _selectedAddress ?? _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zip_code': _zipCodeController.text.trim(),  // Note: database uses zip_code, not zipCode
        'latitude': _selectedLat,
        'longitude': _selectedLng,
      };

      print('🏢 Business Profile - Saving changes: $updateData');
      
      // Call actual API to update business profile
      final businessService = BusinessService();
      
      // Debug: Check if we have a valid business ID
      if (currentUser.businessId == null || currentUser.businessId!.isEmpty) {
        throw Exception('No business ID found for user. User might not have a business profile yet.');
      }
      
      print('🔄 Attempting to update business with ID: ${currentUser.businessId}');
      print('🔄 User ID: ${currentUser.id}');
      
      final result = await businessService.updateBusiness(
        currentUser.businessId!, 
        updateData,
      );
      
      if (result.isFailure) {
        throw Exception(result.error);
      }
      
      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });
      
      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Profile Updated'),
          ],
        ),
        content: const Text(
          'Your business profile has been updated successfully!',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your business account? This will make your business invisible to customers and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deactivation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivation coming soon'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}