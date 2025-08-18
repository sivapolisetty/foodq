import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/enums/user_type.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserType? selectedUserType;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildRoleCards(),
                    const SizedBox(height: 40),
                    _buildContinueButton(),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            Icons.people_alt,
            size: 50,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Choose Your Role',
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Select how you want to use GrabEat to get personalized features',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCards() {
    return Column(
      children: [
        _buildRoleCard(
          userType: UserType.customer,
          title: 'I\'m a Customer',
          description: 'Browse deals, order food, and discover amazing restaurants near you',
          icon: Icons.shopping_bag_outlined,
          features: [
            'Browse restaurant deals',
            'Order food for pickup',
            'Save favorite restaurants',
            'Track order history',
          ],
        ),
        const SizedBox(height: 20),
        _buildRoleCard(
          userType: UserType.business,
          title: 'I\'m a Business Owner',
          description: 'Manage your restaurant, create deals, and grow your customer base',
          icon: Icons.store_outlined,
          features: [
            'Create and manage deals',
            'Track sales analytics',
            'Manage orders',
            'Business dashboard',
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserType userType,
    required String title,
    required String description,
    required IconData icon,
    required List<String> features,
  }) {
    final isSelected = selectedUserType == userType;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserType = userType;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  feature,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.primary : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedUserType == null || isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Continue',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'You can change your role later in your profile settings',
      style: AppTextStyles.bodySmall.copyWith(
        color: Colors.grey[500],
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleContinue() async {
    if (selectedUserType == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Update user profile with selected role
      final authNotifier = ref.read(currentAuthUserProvider.notifier);
      await authNotifier.updateProfile({
        'user_type': selectedUserType!.name,
      });

      if (mounted) {
        // Navigate based on selected role
        if (selectedUserType == UserType.business) {
          context.pushReplacementNamed('businessHome');
        } else {
          context.pushReplacementNamed('home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}