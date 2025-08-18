import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/widgets/overflow_safe_wrapper.dart';
import '../../../shared/widgets/responsive_layout.dart';
import '../../auth/services/production_auth_service.dart';
import '../../auth/providers/auth_provider.dart';

class BusinessWaitingListScreen extends ConsumerStatefulWidget {
  final OnboardingStatus onboardingStatus;
  
  const BusinessWaitingListScreen({
    super.key,
    required this.onboardingStatus,
  });

  @override
  ConsumerState<BusinessWaitingListScreen> createState() => _BusinessWaitingListScreenState();
}

class _BusinessWaitingListScreenState extends ConsumerState<BusinessWaitingListScreen> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OverflowSafeWrapper(
        debugLabel: 'BusinessWaitingListScreen',
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Header Section
                _HeaderSection(businessName: widget.onboardingStatus.businessName)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 40),
                
                // Status Card
                _StatusCard(onboardingStatus: widget.onboardingStatus)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Information Section
                _InformationSection()
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                _ActionButtons(
                  isRefreshing: _isRefreshing,
                  onRefresh: _handleRefresh,
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                
                const SizedBox(height: 24),
                
                // Contact Support Section
                _ContactSupportSection()
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Refresh the current user provider to get updated onboarding status
      final container = ProviderScope.containerOf(context);
      container.invalidate(currentAuthUserProvider);
      
      // Wait a moment for the refresh to process
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh status: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }
}

class _HeaderSection extends StatelessWidget {
  final String? businessName;
  
  const _HeaderSection({this.businessName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Clock/Waiting Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.warning.withOpacity(0.8),
                AppColors.warning,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.schedule,
            color: AppColors.onWarning,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Application Under Review',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        if (businessName != null) ...[
          const SizedBox(height: 8),
          Text(
            businessName!,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final OnboardingStatus onboardingStatus;
  
  const _StatusCard({required this.onboardingStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warningContainer.withOpacity(0.8),
            AppColors.warningContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: Waiting for Approval',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onWarningContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onboardingStatus.businessCreatedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Submitted: ${_formatDate(onboardingStatus.businessCreatedAt!)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onWarningContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your business enrollment has been successfully submitted and is currently being reviewed by our team.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onWarningContainer,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _InformationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'What happens next?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ..._buildInfoItems(),
        ],
      ),
    );
  }

  List<Widget> _buildInfoItems() {
    final items = [
      'Our team will review your business information and documentation',
      'We may contact you if additional information is needed',
      'You\'ll receive a notification once your application is approved',
      'Approval typically takes 1-3 business days',
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < items.length - 1 ? 12 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;
  
  const _ActionButtons({
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Refresh Status Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isRefreshing ? null : onRefresh,
            icon: isRefreshing 
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  )
                : const Icon(Icons.refresh, size: 20),
            label: Text(
              isRefreshing ? 'Checking Status...' : 'Refresh Status',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isRefreshing ? 0 : 2,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // View Profile Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
            icon: const Icon(Icons.person_outline, size: 20),
            label: Text(
              'View Profile',
              style: AppTextStyles.labelLarge,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.7)),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactSupportSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Need Help?',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'If you have questions about your application or need to update your information, please contact our support team.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          TextButton.icon(
            onPressed: () {
              // TODO: Implement contact support functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact support functionality coming soon!'),
                ),
              );
            },
            icon: const Icon(Icons.email_outlined, size: 16),
            label: const Text('Contact Support'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}