import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/widgets/custom_bottom_nav.dart';
import '../../location/providers/location_preferences_provider.dart';
import '../../location/models/location_preferences.dart';
import '../../cart/widgets/floating_cart_bar.dart';

class ProductionProfileScreen extends ConsumerWidget {
  const ProductionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return ref.watch(currentAuthUserProvider).when(
      data: (user) {
        // If user is null, redirect to auth wrapper instead of showing profile
        if (user == null) {
          return const ProductionAuthWrapper();
        }
        
        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: AppColors.surface,
            elevation: 0,
            foregroundColor: AppColors.onSurface,
          ),
          body: Stack(
            children: [
              OverflowSafeWrapper(
                child: _buildProfileContent(context, ref, user),
              ),
              // Only show cart bar for customer users
              if (!user.isBusiness)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0, // Sit directly on top of bottom navigation
                  child: FloatingCartBar(),
                ),
            ],
          ),
          bottomNavigationBar: currentUserAsync.when(
            data: (currentUser) => currentUser != null ? CustomBottomNav(
              currentIndex: 4, // Profile is index 4
              currentUser: currentUser,
              onTap: (index) => _handleBottomNavTap(context, index, ref),
            ) : null,
            loading: () => null,
            error: (_, __) => null,
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {
    // User should never be null here since we handle it in build method

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(user),
          const SizedBox(height: 32),

          // Account Information Section
          _buildSectionTitle('Account Information'),
          const SizedBox(height: 16),
          _buildInfoCard([
            InfoItem(
              icon: Icons.email,
              title: 'Email',
              value: user.email,
            ),
            InfoItem(
              icon: Icons.person,
              title: 'Name',
              value: user.name,
            ),
            if (user.phone?.isNotEmpty == true)
              InfoItem(
                icon: Icons.phone,
                title: 'Phone',
                value: user.phone!,
              ),
            InfoItem(
              icon: user?.isBusiness == true ? Icons.business : Icons.shopping_bag,
              title: 'Account Type',
              value: user?.isBusiness == true ? 'Restaurant Partner' : 'Customer',
            ),
          ]),
          const SizedBox(height: 32),

          // Business Information Section (only for business users)
          if (user.isBusiness) ...[
            _buildSectionTitle('Business Information'),
            const SizedBox(height: 16),
            _buildInfoCard([
              if (user.businessName?.isNotEmpty == true)
                InfoItem(
                  icon: Icons.store,
                  title: 'Business Name',
                  value: user.businessName!,
                ),
              if (user.businessId?.isNotEmpty == true)
                InfoItem(
                  icon: Icons.badge,
                  title: 'Business ID',
                  value: user.businessId!.substring(0, 8).toUpperCase(),
                ),
              if (user.address?.isNotEmpty == true)
                InfoItem(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: user.address!,
                ),
            ]),
            const SizedBox(height: 32),
          ],

          // Location Preferences Section (only for customers)
          if (!user.isBusiness) ...[
            _buildSectionTitle('Location Preferences'),
            const SizedBox(height: 16),
            _buildLocationPreferencesCard(context, ref),
            const SizedBox(height: 32),
          ],

          // Account Actions
          _buildSectionTitle('Account Actions'),
          const SizedBox(height: 16),
          _buildActionCard(context, ref, user),
          const SizedBox(height: 32),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _signOut(ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
          ),
          child: user.profileImageUrl?.isNotEmpty == true
              ? ClipOval(
                  child: Image.network(
                    user.profileImageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(user.name),
                  ),
                )
              : _buildDefaultAvatar(user.name),
        ),
        const SizedBox(width: 20),

        // Name and type
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: user.isBusiness
                      ? AppColors.primaryContainer
                      : AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  user.isBusiness ? 'Restaurant Partner' : 'Customer',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: user.isBusiness
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoCard(List<InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((entry) => _buildInfoItem(
                  entry.value,
                  isLast: entry.key == items.length - 1,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInfoItem(InfoItem item, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: !isLast
            ? Border(bottom: BorderSide(color: AppColors.outline.withOpacity(0.1)))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            item.icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPreferencesCard(BuildContext context, WidgetRef ref) {
    final locationPrefs = ref.watch(locationPreferencesProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Search Radius Setting
          ListTile(
            leading: Icon(Icons.location_searching, color: AppColors.primary),
            title: const Text('Search Radius'),
            subtitle: Text('Find restaurants within ${ref.read(locationPreferencesProvider.notifier).radiusDisplayText}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showSearchRadiusDialog(context, ref),
          ),
          
          // Auto-detect Location Setting
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto-detect Location',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Automatically detect your current location',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: locationPrefs.autoDetectLocation,
                  onChanged: (value) {
                    ref.read(locationPreferencesProvider.notifier).updateAutoDetectLocation(value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          
          // Last Known Location (if available)
          if (locationPrefs.lastKnownAddress.isNotEmpty) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.location_history, color: AppColors.onSurfaceVariant),
              title: const Text('Last Known Location'),
              subtitle: Text(
                locationPrefs.lastKnownAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => _clearLastKnownLocation(context, ref),
                tooltip: 'Clear last known location',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, WidgetRef ref, user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: AppColors.primary),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your personal information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showEditProfileDialog(context, ref, user),
          ),
          if (user.isBusiness) ...[
            ListTile(
              leading: Icon(Icons.business, color: AppColors.primary),
              title: const Text('Edit Business Profile'),
              subtitle: const Text('Update restaurant information'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go('/business-profile'),
            ),
          ],
          ListTile(
            leading: Icon(Icons.help, color: AppColors.primary),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help with your account'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showHelpDialog(context),
          ),
        ],
      ),
    );
  }

  void _showSearchRadiusDialog(BuildContext context, WidgetRef ref) {
    final currentRadius = ref.read(locationPreferencesProvider).searchRadiusMiles;
    double selectedRadius = currentRadius;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_searching, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Search Radius'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Find restaurants within ${selectedRadius.toInt()} miles',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                    valueIndicatorColor: AppColors.primary,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: selectedRadius,
                    min: 30.0,
                    max: 50.0,
                    divisions: 20,
                    label: '${selectedRadius.toInt()} miles',
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRadius = value;
                      });
                    },
                  ),
                ),
                
                // Range indicator
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '30 miles',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '50 miles',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This setting controls how far from your location restaurants will be shown in search results.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onInfoContainer,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(locationPreferencesProvider.notifier).updateSearchRadius(selectedRadius);
                Navigator.of(context).pop();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Search radius updated to ${selectedRadius.toInt()} miles'),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearLastKnownLocation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Last Known Location'),
        content: const Text(
          'Are you sure you want to clear your last known location? '
          'You will need to set your location again when using the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(locationPreferencesProvider.notifier).updateLastKnownLocation(
                address: '',
                latitude: null,
                longitude: null,
              );
              Navigator.of(context).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Last known location cleared'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email cannot be changed for security reasons.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(context, ref, {
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim(),
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditBusinessProfileDialog(BuildContext context, WidgetRef ref, user) {
    final businessNameController = TextEditingController(text: user.businessName ?? '');
    final addressController = TextEditingController(text: user.address ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Business Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Business Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Changes to business information may require approval.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onInfoContainer,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateProfile(context, ref, {
                'business_name': businessNameController.text.trim(),
                'address': addressController.text.trim(),
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(BuildContext context, WidgetRef ref, Map<String, String> updates) async {
    try {
      final authNotifier = ref.read(currentAuthUserProvider.notifier);
      await authNotifier.updateProfile(updates);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'For support, please contact us at:\n\n'
          'Email: support@grabeat.com\n'
          'Phone: +1 (555) 123-4567\n\n'
          'We\'re here to help!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index, WidgetRef ref) {
    final currentUserAsync = ref.read(authenticatedUserProvider);
    final currentUser = currentUserAsync.valueOrNull;
    
    if (currentUser?.isBusiness == true) {
      // Business navigation
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
          // Already on profile, do nothing
          break;
      }
    } else {
      // Customer navigation
      switch (index) {
        case 0:
          context.go('/customer-home');
          break;
        case 1:
          context.go('/search');
          break;
        case 2:
          context.go('/favorites');
          break;
        case 3:
          context.go('/orders');
          break;
        case 4:
          // Already on profile, do nothing
          break;
      }
    }
  }

  Future<void> _signOut(WidgetRef ref) async {
    try {
      // Use the comprehensive logout utility
      await performCompleteLogout(ref);
    } catch (e) {
      print('💥 Error signing out: $e');
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Error loading profile',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}

class InfoItem {
  final IconData icon;
  final String title;
  final String value;

  const InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}