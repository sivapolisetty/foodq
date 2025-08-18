import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class BusinessGuidelines extends StatelessWidget {
  const BusinessGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.rule,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Business Guidelines',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _GuidelineItem(
              icon: Icons.verified_user,
              title: 'Approval Process',
              description: 'All businesses are reviewed within 1-2 business days to ensure quality and safety standards.',
              color: AppColors.primary,
            ),
            
            const SizedBox(height: 12),
            
            _GuidelineItem(
              icon: Icons.health_and_safety,
              title: 'Food Safety',
              description: 'Must maintain current food safety certifications and follow local health department regulations.',
              color: AppColors.success,
            ),
            
            const SizedBox(height: 12),
            
            _GuidelineItem(
              icon: Icons.schedule,
              title: 'Deal Posting',
              description: 'Post deals for surplus food only. Items must be fresh and safe for consumption.',
              color: AppColors.secondary,
            ),
            
            const SizedBox(height: 12),
            
            _GuidelineItem(
              icon: Icons.support_agent,
              title: 'Customer Service',
              description: 'Respond to customer inquiries promptly and maintain professional communication.',
              color: AppColors.info,
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.eco,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Join the movement to reduce food waste and help the environment!',
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
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _GuidelineItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}