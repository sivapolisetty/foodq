import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Partnership Benefits Section Widget
/// Displays the three main benefits of joining GrabEat as a restaurant partner
class PartnershipBenefitsSection extends StatelessWidget {
  const PartnershipBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Join GrabEat?',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Join thousands of restaurants already reducing waste and increasing revenue',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Benefits Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildBenefitCard(
                      icon: Icons.attach_money,
                      title: 'Increase Revenue',
                      subtitle: 'Convert surplus food into additional income instead of waste',
                      color: const Color(0xFF4CAF50),
                      delay: 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBenefitCard(
                      icon: Icons.eco,
                      title: 'Reduce Food Waste',
                      subtitle: 'Help the environment by reducing food waste in your community',
                      color: const Color(0xFF2E7D32),
                      delay: 100,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Full width benefit card
              _buildBenefitCard(
                icon: Icons.people,
                title: 'Reach New Customers',
                subtitle: 'Connect with deal-seeking customers and build loyalty through our platform',
                color: const Color(0xFF1976D2),
                delay: 200,
                isFullWidth: true,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Additional Benefits List
          _buildAdditionalBenefits(),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (isFullWidth) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          if (!isFullWidth) ...[
            const SizedBox(height: 12),
            
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            
            const SizedBox(height: 6),
            
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    ).animate()
     .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
     .slideY(begin: 0.2, end: 0);
  }

  Widget _buildAdditionalBenefits() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Benefits',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Column(
            children: [
              _buildBenefitItem('📱', 'Easy-to-use dashboard for deal management'),
              _buildBenefitItem('🔔', 'Real-time notifications when customers place orders'),
              _buildBenefitItem('📊', 'Analytics and insights to optimize your offerings'),
              _buildBenefitItem('🎯', 'Marketing support to reach more customers'),
              _buildBenefitItem('💳', 'Secure payment processing with quick payouts'),
              _buildBenefitItem('🏆', 'Build reputation through customer reviews'),
            ],
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(delay: 400.ms, duration: 600.ms)
    .slideY(begin: 0.1, end: 0);
  }

  Widget _buildBenefitItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}