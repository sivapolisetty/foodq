import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/enums/user_type.dart';

/// Widget that displays the current user's profile information
/// Shows different layouts for business vs customer users
class UserProfileHeader extends ConsumerWidget {
  final AppUser user;

  const UserProfileHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Profile avatar
              _buildProfileAvatar(),
              
              const SizedBox(width: 16),
              
              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212121),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (user.phone?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phone!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // User type badge
              _buildUserTypeBadge(),
            ],
          ),
          
          // Business info section (only for business users)
          if (user.isBusiness) ...[
            const SizedBox(height: 24),
            _buildBusinessInfo(),
          ],
          
          // Account stats section
          const SizedBox(height: 24),
          _buildAccountStats(),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: user.isBusiness
              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
              : [const Color(0xFF2196F3), const Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (user.isBusiness 
                ? const Color(0xFF4CAF50)
                : const Color(0xFF2196F3)).withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(user.name),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeBadge() {
    final isBusinessUser = user.isBusiness;
    final badgeColor = isBusinessUser 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFF2196F3);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isBusinessUser ? Icons.business : Icons.person,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            user.userType.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              const Text(
                'Business Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBusinessInfoRow(
            'Business ID',
            user.businessId ?? 'Not assigned',
            Icons.store,
          ),
          const SizedBox(height: 12),
          _buildBusinessInfoRow(
            'Account Type',
            'Business Owner',
            Icons.admin_panel_settings,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF757575),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Active Since',
              _formatDate(user.createdAt),
              Icons.calendar_today,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE0E0E0),
          ),
          Expanded(
            child: _buildStatItem(
              'Profile Status',
              'Active',
              Icons.check_circle,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final itemColor = color ?? const Color(0xFF757575);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: itemColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: itemColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays < 30) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}