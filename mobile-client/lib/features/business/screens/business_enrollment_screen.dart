import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../providers/business_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/business_enrollment_form.dart';
import '../widgets/business_guidelines.dart';
import '../widgets/image_upload_section.dart';
import '../widgets/location_selector.dart';

class BusinessEnrollmentScreen extends ConsumerWidget {
  const BusinessEnrollmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessStateProvider);
    final enrollmentForm = ref.watch(businessEnrollmentFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Your Business'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: OverflowSafeWrapper(
        debugLabel: 'BusinessEnrollmentScreen',
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                _HeaderSection()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 32),
                
                // Business Guidelines
                const BusinessGuidelines()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Enrollment Form
                const BusinessEnrollmentForm()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),
                
                // Location Selector
                const LocationSelector()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 600.ms)
                    .slideX(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),
                
                // Image Upload Section
                const ImageUploadSection()
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Enroll Button
                _EnrollButton()
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                
                const SizedBox(height: 24),
                
                // Loading/Error States
                if (businessState.isEnrolling)
                  const _LoadingState()
                    .animate()
                    .fadeIn(duration: 300.ms),
                
                if (businessState.error != null)
                  _ErrorState(error: businessState.error!)
                    .animate()
                    .slideY(begin: -0.5, end: 0, duration: 300.ms),
                
                if (businessState.business != null && !businessState.isEnrolling)
                  _SuccessState(business: businessState.business!)
                    .animate()
                    .slideY(begin: 0.5, end: 0, duration: 500.ms)
                    .then()
                    .shimmer(duration: 1000.ms)
                    .then(delay: 2000.ms)
                    .callback(callback: (_) {
                      // Navigate to dashboard after success animation
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Business Icon
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
            Icons.business,
            color: AppColors.onPrimary,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Enroll Your Business',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Join KraveKart and start reducing food waste while reaching more customers',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EnrollButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessState = ref.watch(businessStateProvider);
    final enrollmentForm = ref.watch(businessEnrollmentFormProvider);
    final businessNotifier = ref.watch(businessStateProvider.notifier);
    final formNotifier = ref.watch(businessEnrollmentFormProvider.notifier);

    return ElevatedButton(
      key: const Key('enroll_business_button'),
      onPressed: businessState.isEnrolling
          ? null
          : () => _handleEnrollment(ref, formNotifier, businessNotifier),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: businessState.isEnrolling ? 0 : 2,
      ),
      child: businessState.isEnrolling
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business_center, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Enroll Business',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }

  void _handleEnrollment(
    WidgetRef ref,
    BusinessEnrollmentFormNotifier formNotifier,
    BusinessStateNotifier businessNotifier,
  ) {
    // Validate form first
    formNotifier.validateForm();
    
    final form = ref.read(businessEnrollmentFormProvider);
    if (!form.isValid) {
      return;
    }

    // Get current user ID from authenticated user
    final currentUserAsync = ref.read(currentAuthUserProvider);
    final currentUser = currentUserAsync.valueOrNull;
    if (currentUser == null) {
      // Should not happen since this screen is only accessible to authenticated users
      return;
    }

    // Perform enrollment
    businessNotifier.enrollBusiness(
      ownerId: currentUser.id,
      name: form.name,
      description: form.description,
      address: form.address,
      latitude: form.latitude!,
      longitude: form.longitude!,
      phone: form.phone.isNotEmpty ? form.phone : null,
      email: form.email.isNotEmpty ? form.email : null,
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Enrolling...',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your application',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enrollment Failed',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(businessStateProvider.notifier).clearError(),
            icon: Icon(
              Icons.close,
              color: AppColors.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final business;

  const _SuccessState({required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.successContainer,
            AppColors.successContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.onSuccess,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Business Successfully Enrolled!',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.onSuccessContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Your business "${business.name}" has been submitted for approval. You\'ll receive a notification once it\'s reviewed.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSuccessContainer,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status: Pending Approval',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSuccessContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}