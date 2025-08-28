import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/enums/user_type.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../../auth/services/production_auth_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/widgets/custom_bottom_nav.dart';

class ProductionProfileScreen extends ConsumerWidget {
  const ProductionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
      ),
      body: OverflowSafeWrapper(
        child: ref.watch(currentAuthUserProvider).when(
          data: (user) => _buildProfileContent(context, ref, user),
          loading: () => _buildLoadingState(),
          error: (error, stackTrace) => _buildErrorState(error),
        ),
      ),
      bottomNavigationBar: currentUserAsync.when(
        data: (currentUser) => currentUser != null ? CustomBottomNav(
          currentIndex: 4, // Profile is index 4
          currentUser: currentUser,
          onTap: (index) => _handleBottomNavTap(context, index),
        ) : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, user) {
    if (user == null) {
      return _buildNotAuthenticatedState();
    }

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

  Widget _buildActionCard(BuildContext context, WidgetRef ref, user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Role switching options
          if (user.isCustomer) ...[
            ListTile(
              leading: Icon(Icons.business, color: AppColors.primary),
              title: const Text('Become a Restaurant Partner'),
              subtitle: const Text('Start selling on grabeat'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showRoleChangeDialog(context, ref, UserType.business),
            ),
          ] else if (user.isBusiness) ...[
            ListTile(
              leading: Icon(Icons.shopping_bag, color: AppColors.primary),
              title: const Text('Switch to Customer Account'),
              subtitle: const Text('Browse and order food'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showRoleChangeDialog(context, ref, UserType.customer),
            ),
          ],
          ListTile(
            leading: Icon(Icons.edit, color: AppColors.primary),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showEditProfileDialog(context, ref, user),
          ),
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

  Future<void> _showRoleChangeDialog(BuildContext context, WidgetRef ref, UserType newRole) async {
    final isBecomingBusiness = newRole == UserType.business;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBecomingBusiness 
          ? 'Become a Restaurant Partner?' 
          : 'Switch to Customer Account?'),
        content: Text(isBecomingBusiness 
          ? 'This will change your account to a restaurant partner account. '
            'You\'ll need to complete restaurant onboarding to start selling.'
          : 'This will change your account to a customer account. '
            'You can browse and order food from restaurants.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateUserRole(context, ref, newRole);
    }
  }

  Future<void> _updateUserRole(BuildContext context, WidgetRef ref, UserType newRole) async {
    try {
      final authNotifier = ref.read(currentAuthUserProvider.notifier);
      await authNotifier.updateProfile({'user_type': newRole.name});
      
      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Account switched to ${newRole.displayName}'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate based on new role
        if (newRole == UserType.business) {
          context.pushReplacementNamed('businessHome');
        } else {
          context.pushReplacementNamed('home');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref, user) {
    // TODO: Implement edit profile dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile feature coming soon!')),
    );
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

  void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
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

  Future<void> _signOut(WidgetRef ref) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // The auth wrapper will handle navigation back to login
    } catch (e) {
      print('Error signing out: $e');
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

  Widget _buildNotAuthenticatedState() {
    return const Center(
      child: Text('Not authenticated'),
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