import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/deal.dart';
import '../models/api_models.dart';
import '../services/expired_deals_api_service.dart';

/// Clean API-driven expired deals section
/// Uses backend for all regret calculations and messaging
class ExpiredDealsApiSection extends StatefulWidget {
  final Function(Deal)? onDealTap;
  final VoidCallback? onSeeAllExpired;
  final VoidCallback? onEnableNotifications;
  final int maxVisible;
  final bool showStats;
  final bool showOnlyRecentlyExpired;
  
  const ExpiredDealsApiSection({
    super.key,
    this.onDealTap,
    this.onSeeAllExpired,
    this.onEnableNotifications,
    this.maxVisible = 4,
    this.showStats = true,
    this.showOnlyRecentlyExpired = false,
  });

  @override
  State<ExpiredDealsApiSection> createState() => _ExpiredDealsApiSectionState();
}

class _ExpiredDealsApiSectionState extends State<ExpiredDealsApiSection> {
  List<ExpiredDeal> _expiredDeals = [];
  ExpiredDealStats? _stats;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadExpiredDeals();
  }
  
  Future<void> _loadExpiredDeals() async {
    print('🕒 EXPIRED_WIDGET: Starting _loadExpiredDeals()');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      late Future<List<ExpiredDeal>> dealsFuture;
      
      if (widget.showOnlyRecentlyExpired) {
        dealsFuture = ExpiredDealsApiService.getRecentlyExpiredDeals();
      } else {
        dealsFuture = ExpiredDealsApiService.getExpiredDeals();
      }
      
      final futures = await Future.wait([
        dealsFuture,
        if (widget.showStats) ExpiredDealsApiService.getExpiredDealsStats(),
      ]);
      
      setState(() {
        _expiredDeals = futures[0] as List<ExpiredDeal>;
        if (widget.showStats && futures.length > 1) {
          _stats = futures[1] as ExpiredDealStats?;
        }
      });
      
      print('🕒 EXPIRED_WIDGET: Successfully loaded ${_expiredDeals.length} expired deals');
      if (widget.showStats && _stats != null) {
        print('🕒 EXPIRED_WIDGET: Stats - totalExpired: ${_stats!.totalExpired}, recentlyExpired: ${_stats!.recentlyExpired}');
      }
    } catch (e) {
      print('🕒 EXPIRED_WIDGET: Error loading expired deals: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    if (_expiredDeals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getExpiredSectionBorderColor(),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _getExpiredSectionBorderColor().withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (widget.showStats && _stats != null) _buildStats(),
          _buildExpiredDealsList(),
          _buildFooter(),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.missedGray),
            const SizedBox(height: 12),
            Text(
              'Loading expired deals...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Expired Deals',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadExpiredDeals,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    final maxRegretCount = _expiredDeals.where((d) => d.regretLevel == 'maximum').length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getHeaderBackgroundColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getHeaderIconColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getHeaderIcon(),
              color: _getHeaderIconColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getHeaderTitle(),
                  style: AppTextStyles.urgentAction.copyWith(
                    color: _getHeaderTextColor(),
                    fontSize: 16,
                  ),
                ),
                if (maxRegretCount > 0)
                  Text(
                    "$maxRegretCount from your cart!",
                    style: AppTextStyles.timeLeft.copyWith(
                      color: AppColors.urgentPulse,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onSeeAllExpired != null)
            TextButton(
              onPressed: widget.onSeeAllExpired,
              child: Text(
                'See All',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.missedGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStats() {
    if (_stats == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.missedGray.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.missedGray.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Total Expired',
                value: '${_stats!.totalExpired}',
                color: AppColors.missedGray,
              ),
              _buildStatItem(
                label: 'From Cart',
                value: '${_stats!.cartExpired}',
                color: AppColors.urgentPulse,
              ),
              _buildStatItem(
                label: 'Missed Value',
                value: '\$${_stats!.totalExpiredValue.toStringAsFixed(0)}',
                color: AppColors.premiumGold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.missedGray.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _stats!.primaryRegretMessage,
              style: AppTextStyles.missedOpportunity.copyWith(
                color: AppColors.onSurface,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpiredDealsList() {
    final visibleDeals = _expiredDeals.take(widget.maxVisible).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...visibleDeals.map((expired) => _buildExpiredDealItem(expired)).toList(),
          if (_expiredDeals.length > widget.maxVisible)
            _buildViewMoreButton(),
        ],
      ),
    );
  }
  
  Widget _buildExpiredDealItem(ExpiredDeal expired) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getRegretColor(expired.displayRegretLevel).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRegretColor(expired.displayRegretLevel).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Grayscale deal indicator
          CircleAvatar(
            backgroundColor: AppColors.missedGray,
            child: Icon(
              Icons.history,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Deal info with regret messaging from server
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired.deal.title,
                  style: AppTextStyles.dealTitle.copyWith(
                    fontSize: 14,
                    color: AppColors.missedGray,
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Regret message from server
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRegretColor(expired.displayRegretLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    expired.regretMessage,
                    style: AppTextStyles.caption.copyWith(
                      color: _getRegretColor(expired.displayRegretLevel),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Price and time since expiry
                Row(
                  children: [
                    Text(
                      expired.deal.formattedDiscountedPrice,
                      style: AppTextStyles.priceDiscounted.copyWith(
                        fontSize: 14,
                        color: AppColors.missedGray,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.missedGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expired.expiryUrgencyMessage,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 9,
                          color: AppColors.missedGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Regret level indicator
          Column(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: _getRegretColor(expired.displayRegretLevel),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getRegretEmoji(expired.displayRegretLevel),
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewMoreButton() {
    final remainingCount = _expiredDeals.length - widget.maxVisible;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: widget.onSeeAllExpired,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.missedGray.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: AppColors.missedGray.withOpacity(0.3),
            ),
          ),
        ),
        child: Text(
          'View $remainingCount more expired deals',
          style: AppTextStyles.buttonText.copyWith(
            color: AppColors.missedGray,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.warning,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _stats?.secondaryRegretMessage ?? "Don't let this happen again",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.onEnableNotifications != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onEnableNotifications,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 16,
                ),
                label: Text(
                  'Enable Deal Alerts',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.savingsPrice.copyWith(
            color: color,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
  
  // Helper methods for dynamic styling
  
  Color _getExpiredSectionBorderColor() {
    final maxRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'maximum');
    if (maxRegretDeals.isNotEmpty) return AppColors.urgentPulse;
    
    final highRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'high');
    if (highRegretDeals.isNotEmpty) return AppColors.almostGone;
    
    return AppColors.missedGray;
  }
  
  Color _getHeaderBackgroundColor() {
    final maxRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'maximum');
    if (maxRegretDeals.isNotEmpty) return AppColors.urgentPulse.withOpacity(0.1);
    
    return AppColors.missedGray.withOpacity(0.05);
  }
  
  IconData _getHeaderIcon() {
    final maxRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'maximum');
    if (maxRegretDeals.isNotEmpty) return Icons.heart_broken;
    
    return Icons.history;
  }
  
  Color _getHeaderIconColor() {
    final maxRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'maximum');
    if (maxRegretDeals.isNotEmpty) return AppColors.urgentPulse;
    
    return AppColors.missedGray;
  }
  
  Color _getHeaderTextColor() {
    final maxRegretDeals = _expiredDeals.where((d) => d.regretLevel == 'maximum');
    if (maxRegretDeals.isNotEmpty) return AppColors.urgentPulse;
    
    return AppColors.onSurface;
  }
  
  String _getHeaderTitle() {
    final maxRegretCount = _expiredDeals.where((d) => d.regretLevel == 'maximum').length;
    
    if (maxRegretCount > 0) {
      return "Deals Expired From Your Cart!";
    } else if (widget.showOnlyRecentlyExpired) {
      return "Recently Expired Deals";
    } else {
      return "Expired Deals";
    }
  }
  
  Color _getRegretColor(RegretLevel level) {
    switch (level) {
      case RegretLevel.maximum:
        return AppColors.urgentPulse;
      case RegretLevel.high:
        return AppColors.almostGone;
      case RegretLevel.medium:
        return AppColors.limitedTime;
      case RegretLevel.low:
        return AppColors.missedGray;
    }
  }
  
  String _getRegretEmoji(RegretLevel level) {
    switch (level) {
      case RegretLevel.maximum:
        return '💔';
      case RegretLevel.high:
        return '😢';
      case RegretLevel.medium:
        return '😕';
      case RegretLevel.low:
        return '😐';
    }
  }
}