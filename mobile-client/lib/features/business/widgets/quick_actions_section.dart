import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/app_user.dart';

/// Quick actions section for business dashboard
/// Provides shortcuts to common business tasks
class QuickActionsSection extends StatelessWidget {
  final AppUser businessUser;

  const QuickActionsSection({
    Key? key,
    required this.businessUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Grid of quick action cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 16) / 2; // Account for spacing
              final cardHeight = cardWidth * 0.85; // Adjusted aspect ratio
              
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildActionCard(
                      title: 'Create Deal',
                      subtitle: 'Add new deal offer',
                      icon: Icons.add_business,
                      color: const Color(0xFF4CAF50),
                      onTap: () => _navigateToCreateDeal(context),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildActionCard(
                      title: 'View Orders',
                      subtitle: 'Manage incoming orders',
                      icon: Icons.receipt_long,
                      color: const Color(0xFF2196F3),
                      onTap: () => _navigateToOrders(context),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildActionCard(
                      title: 'Business Profile',
                      subtitle: 'Update restaurant info',
                      icon: Icons.store,
                      color: const Color(0xFFFF9800),
                      onTap: () => _navigateToBusinessProfile(context),
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: _buildActionCard(
                      title: 'Analytics',
                      subtitle: 'View performance data',
                      icon: Icons.analytics,
                      color: const Color(0xFF9C27B0),
                      onTap: () => _navigateToAnalytics(context),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreateDeal(BuildContext context) {
    context.go('/deals');
  }

  void _navigateToOrders(BuildContext context) {
    context.go('/orders');
  }

  void _navigateToBusinessProfile(BuildContext context) {
    context.go('/business-profile');
  }

  void _navigateToAnalytics(BuildContext context) {
    // TODO: Implement analytics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics dashboard coming soon!'),
        backgroundColor: Color(0xFF9C27B0),
      ),
    );
  }
}