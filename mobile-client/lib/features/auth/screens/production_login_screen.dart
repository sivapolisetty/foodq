import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../widgets/grabeat_logo.dart';
import '../providers/auth_provider.dart';
import '../services/production_auth_service.dart';

class ProductionLoginScreen extends ConsumerStatefulWidget {
  const ProductionLoginScreen({super.key});

  @override
  ConsumerState<ProductionLoginScreen> createState() => _ProductionLoginScreenState();
}

class _ProductionLoginScreenState extends ConsumerState<ProductionLoginScreen> {
  bool _isLoading = false;
  String? _selectedRole;
  
  final Map<String, RoleInfo> _roleOptions = {
    'customer': RoleInfo(
      title: 'Customer',
      subtitle: 'Find and order discounted meals',
      icon: Icons.shopping_bag,
      description: 'Discover great deals on surplus food from local restaurants',
    ),
    'business': RoleInfo(
      title: 'Restaurant Partner',
      subtitle: 'List your surplus food and reduce waste',
      icon: Icons.store,
      description: 'Join grabeat to reach more customers and minimize food waste',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OverflowSafeWrapper(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and welcome
                    const GrabeatLogo(size: 100),
                    const SizedBox(height: 32),
                    
                    // Welcome text
                    Text(
                      'Welcome to grabeat',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you\'d like to use grabeat',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Role selection cards
                    ..._roleOptions.entries.map((entry) => _buildRoleCard(
                      entry.key,
                      entry.value,
                    )),
                    
                    const SizedBox(height: 32),

                    // Continue with Google button
                    if (_selectedRole != null) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.login, size: 20),
                                ),
                          label: Text(
                            _isLoading 
                                ? 'Signing in...' 
                                : 'Continue with Google',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Terms and privacy
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String roleKey, RoleInfo roleInfo) {
    final isSelected = _selectedRole == roleKey;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => _selectedRole = roleKey),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Role icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  roleInfo.icon,
                  color: isSelected ? AppColors.onPrimary : AppColors.surface,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Role info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleInfo.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleInfo.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected ? AppColors.onPrimaryContainer.withOpacity(0.8) : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_selectedRole == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Store selected role for later use
      await _storeSelectedRole(_selectedRole!);
      
      // Get platform-appropriate redirect URL
      final redirectTo = _getRedirectUrl();
      
      final response = await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response) {
        // OAuth launched successfully
        // The app will handle the callback in AuthWrapper
        // Store the selected role for when the user returns
        _storeSelectedRole(_selectedRole!);
      } else {
        _showError('Failed to launch Google Sign-In');
      }
    } catch (error) {
      _showError('Sign-in failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getRedirectUrl() {
    if (kIsWeb) {
      // For web, use current location with auth callback
      return '${Uri.base.origin}/auth/callback';
    } else {
      // For mobile apps, use deep link that matches the intent filter
      return 'com.grabeat.grabeat://login-callback';
    }
  }

  Future<void> _storeSelectedRole(String role) async {
    try {
      // Store role in production auth service for later use
      final authService = ProductionAuthService();
      await authService.storeSelectedRole(role);
      print('Selected role stored: $role');
    } catch (e) {
      print('Failed to store selected role: $e');
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

class RoleInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  const RoleInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });
}