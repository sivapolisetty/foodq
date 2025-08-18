import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/app_user.dart';
import '../../auth/widgets/production_auth_wrapper.dart';

/// Provider for onboarding status
final onboardingStatusProvider = FutureProvider.autoDispose<OnboardingStatus>((ref) async {
  final currentUser = ref.watch(authenticatedUserProvider).valueOrNull;
  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  final response = await ApiService.get<OnboardingStatus>(
    '/api/users/${currentUser.id}/onboarding-status',
    fromJson: (data) => OnboardingStatus.fromJson(data),
  );

  if (response.success && response.data != null) {
    return response.data!;
  }
  
  throw Exception(response.error ?? 'Failed to fetch onboarding status');
});

class OnboardingStatus {
  final bool needsOnboarding;
  final bool hasBusiness;
  final bool hasPendingRequest;
  final PendingRequest? pendingRequest;
  final BusinessStatus? businessStatus;

  OnboardingStatus({
    required this.needsOnboarding,
    required this.hasBusiness,
    required this.hasPendingRequest,
    this.pendingRequest,
    this.businessStatus,
  });

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      needsOnboarding: json['needs_onboarding'] ?? false,
      hasBusiness: json['has_business'] ?? false,
      hasPendingRequest: json['has_pending_request'] ?? false,
      pendingRequest: json['pending_request'] != null
          ? PendingRequest.fromJson(json['pending_request'])
          : null,
      businessStatus: json['business_status'] != null
          ? BusinessStatus.fromJson(json['business_status'])
          : null,
    );
  }
}

class PendingRequest {
  final String id;
  final String status;
  final String restaurantName;
  final String submissionDate;

  PendingRequest({
    required this.id,
    required this.status,
    required this.restaurantName,
    required this.submissionDate,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'],
      status: json['status'],
      restaurantName: json['restaurant_name'],
      submissionDate: json['submission_date'],
    );
  }
}

class BusinessStatus {
  final String name;
  final bool isApproved;
  final bool onboardingCompleted;
  final String createdAt;

  BusinessStatus({
    required this.name,
    required this.isApproved,
    required this.onboardingCompleted,
    required this.createdAt,
  });

  factory BusinessStatus.fromJson(Map<String, dynamic> json) {
    return BusinessStatus(
      name: json['name'],
      isApproved: json['is_approved'] ?? false,
      onboardingCompleted: json['onboarding_completed'] ?? false,
      createdAt: json['created_at'],
    );
  }
}

class BusinessOnboardingStatusScreen extends ConsumerStatefulWidget {
  const BusinessOnboardingStatusScreen({super.key});

  @override
  ConsumerState<BusinessOnboardingStatusScreen> createState() =>
      _BusinessOnboardingStatusScreenState();
}

class _BusinessOnboardingStatusScreenState
    extends ConsumerState<BusinessOnboardingStatusScreen> {

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(onboardingStatusProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: statusAsync.when(
        data: (status) {
          // If approved, redirect to dashboard
          if (status.pendingRequest?.status == 'approved') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/business-home');
            });
            return _buildApprovedState();
          }

          // If needs onboarding, redirect to enrollment
          if (status.needsOnboarding) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/business-enrollment');
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Show pending status
          if (status.hasPendingRequest && status.pendingRequest != null) {
            return _buildPendingState(status.pendingRequest!);
          }

          // Already has business, redirect to dashboard
          if (status.hasBusiness) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/business-home');
            });
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: CircularProgressIndicator());
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildPendingState(PendingRequest request) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  color: Color(0xFFFFA726),
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Application Under Review',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Restaurant Name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  request.restaurantName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Description
              Text(
                'Your business application is currently being reviewed by our team. This typically takes 24-48 hours.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFFFA726),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Application Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildStatusRow('Status', request.status.toUpperCase(), 
                        request.status == 'pending' ? const Color(0xFFFFA726) : const Color(0xFF4CAF50)),
                    const SizedBox(height: 8),
                    _buildStatusRow('Submitted', _formatDate(request.submissionDate), Colors.grey[600]!),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // What's Next Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What happens next?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNextStep('1', 'Our team reviews your application'),
                    _buildNextStep('2', 'We verify your business details'),
                    _buildNextStep('3', 'You\'ll receive an email notification'),
                    _buildNextStep('4', 'Access your business dashboard'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Refresh Button
              TextButton.icon(
                onPressed: () {
                  ref.invalidate(onboardingStatusProvider);
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF4CAF50)),
                label: const Text(
                  'Refresh Status',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Application Approved!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Redirecting to your dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(onboardingStatusProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: valueColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}