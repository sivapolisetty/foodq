import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../widgets/foodq_logo.dart';
import '../services/production_auth_service.dart';
import '../services/auth_logger.dart';

/// User onboarding screen shown when authenticated user has no profile
class UserOnboardingScreen extends ConsumerStatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  ConsumerState<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends ConsumerState<UserOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedRole;
  
  // User data from Google OAuth
  User? _currentUser;
  String _fullName = '';
  String _email = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    _currentUser = Supabase.instance.client.auth.currentUser;
    if (_currentUser != null) {
      setState(() {
        _fullName = _currentUser!.userMetadata?['full_name'] ?? 
                   _currentUser!.userMetadata?['name'] ?? 
                   _currentUser!.email?.split('@')[0] ?? 
                   'User';
        _email = _currentUser!.email ?? '';
        _avatarUrl = _currentUser!.userMetadata?['avatar_url'];
        // Check if role was stored during OAuth
        _selectedRole = _currentUser!.userMetadata?['selected_role'] ?? 'customer';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logo and welcome
              const FoodQAppLogo(size: 80),
              const SizedBox(height: 32),
              
              // Welcome message
              Text(
                'Welcome to grabeat!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Let\'s complete your profile to get started',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Profile card with Google info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Avatar
                    if (_avatarUrl != null)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_avatarUrl!),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      )
                    else
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Name
                    Text(
                      _fullName,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      _email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role selection
                    Text(
                      'I want to use grabeat as:',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildRoleOption('customer', 'Customer', 'Find and order discounted meals', Icons.shopping_bag),
                    const SizedBox(height: 12),
                    _buildRoleOption('business', 'Restaurant Partner', 'List surplus food and reduce waste', Icons.store),
                    
                    const SizedBox(height: 32),

                    // Phone number field (optional)
                    Text(
                      'Phone Number (Optional)',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number (optional)',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      validator: (value) {
                        // Phone number is now optional
                        if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),

              // Complete profile button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Complete Profile',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onPrimary,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign out option
              TextButton(
                onPressed: _isLoading ? null : _signOut,
                child: Text(
                  'Sign out and use different account',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(String roleKey, String title, String subtitle, IconData icon) {
    final isSelected = _selectedRole == roleKey;
    
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.onPrimaryContainer.withValues(alpha: 0.8) : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null || _currentUser == null) {
      if (_selectedRole == null) {
        _showError('Please select how you want to use grabeat');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      AuthLogger.logAuthEvent('Completing user profile onboarding', data: {
        'user_id': _currentUser!.id,
        'selected_role': _selectedRole,
      });

      // Create user profile via API
      final profileData = {
        'id': _currentUser!.id,
        'email': _email,
        'full_name': _fullName,
        'user_type': _selectedRole,
        'phone': _phoneController.text.trim(),
        'avatar_url': _avatarUrl,
      };

      final authService = ProductionAuthService();
      
      // Use the _createUserProfile method by creating a temporary user profile
      // We'll modify the auth service to have a public method for this
      final success = await authService.completeUserOnboarding(profileData);
      
      if (success) {
        AuthLogger.logAuthEvent('User onboarding completed successfully');
        // The auth wrapper will automatically detect the new profile and redirect appropriately
        // No need to manually navigate - the currentUserProvider will refresh
      } else {
        throw Exception('Failed to complete profile setup');
      }
    } catch (e) {
      AuthLogger.logAuthError('_completeProfile', e);
      _showError('Failed to complete profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      _showError('Failed to sign out: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}