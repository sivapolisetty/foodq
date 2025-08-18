import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../services/restaurant_onboarding_service.dart';

class OnboardingCompletionButton extends ConsumerStatefulWidget {
  final String applicationId;
  final VoidCallback? onCompleted;
  
  const OnboardingCompletionButton({
    super.key,
    required this.applicationId,
    this.onCompleted,
  });

  @override
  ConsumerState<OnboardingCompletionButton> createState() => _OnboardingCompletionButtonState();
}

class _OnboardingCompletionButtonState extends ConsumerState<OnboardingCompletionButton> {
  bool _isCompleting = false;
  final _onboardingService = RestaurantOnboardingService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isCompleting ? null : _completeOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: _isCompleting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          _isCompleting ? 'Completing Setup...' : 'Complete Restaurant Setup',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final currentUser = ref.read(authenticatedUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isCompleting = true);

    try {
      final success = await _onboardingService.completeOnboarding(currentUser.id);
      
      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text('Welcome to grabeat! Your restaurant is now live.'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Trigger refresh of auth state to navigate to dashboard
        ref.invalidate(authenticatedUserProvider);
        
        // Call completion callback
        widget.onCompleted?.call();
      } else {
        _showError('Failed to complete onboarding. Please try again.');
      }
    } catch (e) {
      _showError('Error completing onboarding: $e');
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
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