import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../models/restaurant_onboarding_request.dart';
import 'package:go_router/go_router.dart';

/// Application Status Card Widget
/// Displays the current status of a restaurant onboarding application
class ApplicationStatusCard extends StatelessWidget {
  final RestaurantOnboardingRequest application;
  final VoidCallback onRefresh;
  final VoidCallback onSubmitNew;

  const ApplicationStatusCard({
    super.key,
    required this.application,
    required this.onRefresh,
    required this.onSubmitNew,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Header
          Row(
            children: [
              _getStatusIcon(application.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restaurant Application',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.restaurantName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(application.status),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Status Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(application.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(application.status).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusMessage(application.status),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(application.status),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusDescription(application.status),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                
                // Show admin notes if rejected
                if (application.status == 'rejected' && application.adminNotes != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings, 
                                 color: Colors.red[700], size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Admin Notes:',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          application.adminNotes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Application Details
          _buildApplicationDetails(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Show appropriate action button based on status
              Expanded(
                child: _buildActionButton(context),
              ),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 600.ms)
    .slideY(begin: 0.1, end: 0);
  }

  Widget _buildApplicationDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildDetailRow('Restaurant', application.restaurantName),
          _buildDetailRow('Cuisine Type', application.cuisineType),
          _buildDetailRow('Owner', application.ownerName),
          _buildDetailRow('Email', application.ownerEmail),
          _buildDetailRow('Location', application.address),
          _buildDetailRow('Submitted', _formatDate(application.createdAt)),
          
          if (application.reviewedAt != null)
            _buildDetailRow('Reviewed', _formatDate(application.reviewedAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (application.status) {
      case 'approved':
        return ElevatedButton.icon(
          onPressed: () {
            // Navigate to business dashboard
            context.go('/business-home');
          },
          icon: const Icon(Icons.dashboard, size: 18),
          label: const Text('Go to Dashboard'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
      
      case 'rejected':
        return ElevatedButton.icon(
          onPressed: onSubmitNew,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Submit New Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
      
      default:
        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.hourglass_empty, size: 18),
          label: const Text('Under Review'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            side: BorderSide(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
    }
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color iconColor;
    
    switch (status) {
      case 'approved':
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case 'rejected':
        iconData = Icons.cancel;
        iconColor = AppColors.error;
        break;
      case 'under_review':
        iconData = Icons.visibility;
        iconColor = const Color(0xFF2196F3);
        break;
      default:
        iconData = Icons.schedule;
        iconColor = const Color(0xFFF57C00);
        break;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusLabel(status),
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'under_review':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFF57C00);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      default:
        return 'Pending';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'approved':
        return 'Congratulations! You\'re Approved!';
      case 'rejected':
        return 'Application Not Approved';
      case 'under_review':
        return 'Application Under Review';
      default:
        return 'Application Submitted Successfully!';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'approved':
        return 'Your restaurant has been approved! You can now access your dashboard and start posting deals.';
      case 'rejected':
        return 'Your application was not approved at this time. Please review the admin notes below and submit a new application if needed.';
      case 'under_review':
        return 'Our team is currently reviewing your application. We\'ll send you an update within 2-3 business days.';
      default:
        return 'We\'ve received your application and will review it within 2-3 business days. You\'ll receive an email notification with the approval status.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}