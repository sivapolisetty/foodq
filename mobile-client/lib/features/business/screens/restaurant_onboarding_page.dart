import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../../features/home/widgets/custom_bottom_nav.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/widgets/production_auth_wrapper.dart';
import '../widgets/restaurant_onboarding_modal.dart';
import '../widgets/partnership_benefits_section.dart';
import '../widgets/application_status_card.dart';
import '../providers/restaurant_onboarding_provider.dart';

/// Restaurant Partnership Onboarding Page
/// Entry point for restaurants wanting to join GraBeat
class RestaurantOnboardingPage extends ConsumerStatefulWidget {
  const RestaurantOnboardingPage({super.key});

  @override
  ConsumerState<RestaurantOnboardingPage> createState() => _RestaurantOnboardingPageState();
}

class _RestaurantOnboardingPageState extends ConsumerState<RestaurantOnboardingPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load existing application status when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplicationStatus();
    });
  }

  Future<void> _loadApplicationStatus() async {
    final currentUser = ref.read(authenticatedUserProvider).value;
    if (currentUser != null) {
      await ref.read(restaurantOnboardingProvider.notifier).loadUserApplication(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authenticatedUserProvider);
    final onboardingState = ref.watch(restaurantOnboardingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: OverflowSafeWrapper(
        debugLabel: 'RestaurantOnboardingPage',
        child: ResponsiveContainer(
          child: currentUserAsync.when(
            data: (user) => _buildContent(context, user, onboardingState),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Restaurant Partnership',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppUser? user, RestaurantOnboardingState onboardingState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          _buildHeaderSection()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Show application status if exists, otherwise show benefits and form
          if (onboardingState.currentApplication != null) ...[
            // Application Status Card
            ApplicationStatusCard(
              application: onboardingState.currentApplication!,
              onRefresh: _loadApplicationStatus,
              onSubmitNew: () => _showOnboardingModal(context),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: 0.1, end: 0),
          ] else ...[
            // Partnership Benefits Section
            const PartnershipBenefitsSection()
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 32),
            
            // Start Application Button
            _buildStartApplicationButton(context, user)
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ],
          
          const SizedBox(height: 24),
          
          // Additional Information Section
          _buildAdditionalInfoSection()
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Partnership Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.handshake,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            'Join GraBeat as a Restaurant Partner',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Turn your surplus food into revenue while helping reduce food waste',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Quick Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat('500+', 'Partners'),
              _buildQuickStat('50K+', 'Meals Saved'),
              _buildQuickStat('24h', 'Quick Setup'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStartApplicationButton(BuildContext context, AppUser? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Submit your restaurant application in just 5-10 minutes',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _showOnboardingModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.restaurant, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Start Your Application',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'How It Works',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoStep(1, 'Submit Application', 'Fill out our simple 5-minute form with your restaurant details'),
          const SizedBox(height: 12),
          _buildInfoStep(2, 'Quick Review', 'Our team reviews applications within 2-3 business days'),
          const SizedBox(height: 12),
          _buildInfoStep(3, 'Start Selling', 'Get approved and immediately start posting surplus food deals'),
          const SizedBox(height: 12),
          _buildInfoStep(4, 'Earn Revenue', 'Convert food waste into profit while helping the community'),
        ],
      ),
    );
  }

  Widget _buildInfoStep(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              'Something went wrong',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadApplicationStatus(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnboardingModal(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const RestaurantOnboardingModal(),
        transitionDuration: Duration.zero, // We handle animation inside the modal
        reverseTransitionDuration: Duration.zero,
        barrierDismissible: false,
        opaque: false, // Make background transparent
      ),
    ).then((_) {
      // Refresh application status after modal closes
      _loadApplicationStatus();
    });
  }

  Widget _buildBottomNavigation() {
    final currentUser = ref.watch(authenticatedUserProvider).value;
    if (currentUser == null) return const SizedBox.shrink();
    
    return CustomBottomNav(
      currentUser: currentUser,
      currentIndex: -1, // No specific tab selected for this page
    );
  }
}