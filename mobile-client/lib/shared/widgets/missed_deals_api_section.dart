import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/deal.dart';
import '../models/api_models.dart';
import '../services/missed_deals_api_service.dart';

/// Clean API-driven missed deals section
/// Uses backend for all FOMO calculations and messaging
class MissedDealsApiSection extends StatefulWidget {
  final Function(Deal)? onDealTap;
  final VoidCallback? onSeeAllMissed;
  final int maxVisible;
  final bool showStats;
  
  const MissedDealsApiSection({
    super.key,
    this.onDealTap,
    this.onSeeAllMissed,
    this.maxVisible = 3,
    this.showStats = true,
  });

  @override
  State<MissedDealsApiSection> createState() => _MissedDealsApiSectionState();
}

class _MissedDealsApiSectionState extends State<MissedDealsApiSection> {
  List<MissedDeal> _missedDeals = [];
  MissedDealStats? _stats;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadMissedDeals();
  }
  
  Future<void> _loadMissedDeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final futures = await Future.wait([
        MissedDealsApiService.getMissedDeals(),
        if (widget.showStats) MissedDealsApiService.getMissedDealsStats(),
      ]);
      
      setState(() {
        _missedDeals = futures[0] as List<MissedDeal>;
        if (widget.showStats && futures.length > 1) {
          _stats = futures[1] as MissedDealStats?;
        }
      });
    } catch (e) {
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
    
    if (_missedDeals.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMissedSectionBorderColor(),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMissedSectionBorderColor().withOpacity(0.2),
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
          _buildMissedDealsList(),
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
            CircularProgressIndicator(color: AppColors.limitedTime),
            const SizedBox(height: 12),
            Text(
              'Loading missed deals...',
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
            'Error Loading Missed Deals',
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
            onPressed: _loadMissedDeals,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    final criticalCount = _missedDeals.where((d) => d.urgencyLevel == 'critical').length;
    final endingSoonCount = _missedDeals.where((d) => d.isEndingSoon).length;
    
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
          Icon(
            _getHeaderIcon(),
            color: _getHeaderIconColor(),
            size: 24,
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
                if (endingSoonCount > 0)
                  Text(
                    "$endingSoonCount ending soon!",
                    style: AppTextStyles.timeLeft.copyWith(
                      color: AppColors.urgentPulse,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onSeeAllMissed != null)
            TextButton(
              onPressed: widget.onSeeAllMissed,
              child: Text(
                'See All',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
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
        color: AppColors.missedGray.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.missedGray.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Missed',
                value: '${_stats!.totalMissed}',
                color: AppColors.missedGray,
              ),
              _buildStatItem(
                label: 'Ending Soon',
                value: '${_stats!.endingSoon}',
                color: AppColors.urgentPulse,
              ),
              _buildStatItem(
                label: 'Could Save',
                value: '\$${_stats!.totalMissedSavings.toStringAsFixed(0)}',
                color: AppColors.premiumGold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.missedGray.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _stats!.primaryFOMOMessage,
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
  
  Widget _buildMissedDealsList() {
    final visibleDeals = _missedDeals.take(widget.maxVisible).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...visibleDeals.map((missed) => _buildMissedDealItem(missed)).toList(),
          if (_missedDeals.length > widget.maxVisible)
            _buildViewMoreButton(),
        ],
      ),
    );
  }
  
  Widget _buildMissedDealItem(MissedDeal missed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getUrgencyColor(missed.urgencyLevel).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getUrgencyColor(missed.urgencyLevel).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUrgencyColor(missed.urgencyLevel),
          child: Icon(
            Icons.visibility_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          missed.deal.title,
          style: AppTextStyles.dealTitle.copyWith(
            fontSize: 14,
            color: AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOMO message from server
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getUrgencyColor(missed.urgencyLevel).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getUrgencyColor(missed.urgencyLevel).withOpacity(0.3),
                ),
              ),
              child: Text(
                missed.fomoMessage,
                style: AppTextStyles.caption.copyWith(
                  color: _getUrgencyColor(missed.urgencyLevel),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Price and view count
            Row(
              children: [
                Text(
                  missed.deal.formattedDiscountedPrice,
                  style: AppTextStyles.priceDiscounted.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Viewed ${missed.viewCount}x',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: _getUrgencyColor(missed.urgencyLevel),
          size: 16,
        ),
        onTap: () => widget.onDealTap?.call(missed.deal),
      ),
    );
  }
  
  Widget _buildViewMoreButton() {
    final remainingCount = _missedDeals.length - widget.maxVisible;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: TextButton(
        onPressed: widget.onSeeAllMissed,
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
          'View $remainingCount more missed deals',
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
        color: AppColors.primaryContainer.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _stats?.secondaryFOMOMessage ?? "Make faster decisions to avoid missing out",
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 11,
                fontStyle: FontStyle.italic,
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
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
  
  // Helper methods for dynamic styling
  
  Color _getMissedSectionBorderColor() {
    final criticalDeals = _missedDeals.where((d) => d.urgencyLevel == 'critical');
    if (criticalDeals.isNotEmpty) return AppColors.urgentPulse;
    
    final highUrgencyDeals = _missedDeals.where((d) => d.urgencyLevel == 'high');
    if (highUrgencyDeals.isNotEmpty) return AppColors.almostGone;
    
    return AppColors.missedGray;
  }
  
  Color _getHeaderBackgroundColor() {
    final criticalDeals = _missedDeals.where((d) => d.urgencyLevel == 'critical');
    if (criticalDeals.isNotEmpty) return AppColors.urgentPulse.withOpacity(0.1);
    
    return AppColors.missedGray.withOpacity(0.1);
  }
  
  IconData _getHeaderIcon() {
    final criticalDeals = _missedDeals.where((d) => d.urgencyLevel == 'critical');
    if (criticalDeals.isNotEmpty) return Icons.access_time_filled;
    
    return Icons.visibility_off;
  }
  
  Color _getHeaderIconColor() {
    final criticalDeals = _missedDeals.where((d) => d.urgencyLevel == 'critical');
    if (criticalDeals.isNotEmpty) return AppColors.urgentPulse;
    
    return AppColors.missedGray;
  }
  
  Color _getHeaderTextColor() {
    final criticalDeals = _missedDeals.where((d) => d.urgencyLevel == 'critical');
    if (criticalDeals.isNotEmpty) return AppColors.urgentPulse;
    
    return AppColors.onSurface;
  }
  
  String _getHeaderTitle() {
    final criticalCount = _missedDeals.where((d) => d.urgencyLevel == 'critical').length;
    final endingSoonCount = _missedDeals.where((d) => d.isEndingSoon).length;
    
    if (criticalCount > 0) {
      return "Critical: Don't Miss Again!";
    } else if (endingSoonCount > 0) {
      return "Deals Ending Soon";
    } else {
      return "You Missed These Deals";
    }
  }
  
  Color _getUrgencyColor(String urgencyLevel) {
    switch (urgencyLevel) {
      case 'critical':
        return AppColors.urgentPulse;
      case 'high':
        return AppColors.almostGone;
      case 'medium':
        return AppColors.limitedTime;
      default:
        return AppColors.missedGray;
    }
  }
}