import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../home/widgets/custom_bottom_nav.dart';

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
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

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
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBusinessData() {
    // Use a post-frame callback to ensure the provider is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserAsync = ref.read(authenticatedUserProvider);
      currentUserAsync.whenData((user) {
        if (user != null && user.isBusiness) {
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
          
          if (mounted) {
            setState(() {
              _businessNameController.text = user.businessName ?? user.name;
              _descriptionController.text = ''; // Would come from business data
              _addressController.text = user.address ?? '';
              _phoneController.text = user.phone ?? '';
              _emailController.text = user.email;
              _websiteController.text = ''; // Would come from business data
            });
          }
        } else {
          print('🔍 Business Profile Debug - User is null or not business: $user');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);

    return currentUserAsync.when(
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
      title: 'Location',
      icon: Icons.location_on,
      children: [
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Business Address *',
            hintText: '123 Main St, City, State 12345',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business address is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your address helps customers find you and is used for delivery zones.',
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

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual save functionality
      // This would call an API to update the business profile
      
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      setState(() {
        _hasUnsavedChanges = false;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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