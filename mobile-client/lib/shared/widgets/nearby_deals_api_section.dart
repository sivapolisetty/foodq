import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/deal.dart';
import '../models/api_models.dart';
import '../services/location_deals_api_service.dart';

/// Clean API-driven nearby deals section
/// Uses backend for all distance calculations and filtering
class NearbyDealsApiSection extends StatefulWidget {
  final Function(Deal)? onDealTap;
  final VoidCallback? onLocationPermissionRequest;
  final VoidCallback? onSeeAllNearby;
  final bool showDistance;
  final bool groupByDistance;
  final int maxVisible;
  
  const NearbyDealsApiSection({
    super.key,
    this.onDealTap,
    this.onLocationPermissionRequest,
    this.onSeeAllNearby,
    this.showDistance = true,
    this.groupByDistance = false,
    this.maxVisible = 5,
  });

  @override
  State<NearbyDealsApiSection> createState() => _NearbyDealsApiSectionState();
}

class _NearbyDealsApiSectionState extends State<NearbyDealsApiSection> {
  List<DealWithDistance> _nearbyDeals = [];
  LocationDealsGroup? _groupedDeals;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.denied;
  bool _isLoading = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadNearbyDeals();
  }
  
  Future<void> _loadNearbyDeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      _permissionStatus = await LocationDealsApiService.getLocationPermissionStatus();
      
      if (_permissionStatus == LocationPermissionStatus.granted) {
        if (widget.groupByDistance) {
          _groupedDeals = await LocationDealsApiService.getGroupedNearbyDeals();
          setState(() {
            _nearbyDeals = _groupedDeals?.closestDeals ?? [];
          });
        } else {
          final deals = await LocationDealsApiService.getDealsNearUser(
            limit: widget.maxVisible,
          );
          setState(() {
            _nearbyDeals = deals;
          });
        }
      }
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
  
  Future<void> _requestLocationPermission() async {
    final granted = await LocationDealsApiService.requestLocationPermission();
    if (granted) {
      await _loadNearbyDeals();
    }
    widget.onLocationPermissionRequest?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getLocationIcon(),
              color: Colors.white,
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
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getHeaderSubtitle(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadNearbyDeals,
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    if (_error != null) {
      return _buildErrorState();
    }
    
    switch (_permissionStatus) {
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
        return _buildPermissionRequest();
      case LocationPermissionStatus.serviceDisabled:
        return _buildLocationServiceDisabled();
      case LocationPermissionStatus.granted:
        return _buildNearbyDeals();
    }
  }
  
  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Finding deals near you...',
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Nearby Deals',
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
            onPressed: _loadNearbyDeals,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionRequest() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.location_disabled,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Location Access Needed',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We need your location to show deals near you.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _requestLocationPermission,
            icon: Icon(Icons.location_on),
            label: Text('Allow Location Access'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationServiceDisabled() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          Text(
            'Location Services Disabled',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please enable location services in your device settings.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNearbyDeals() {
    if (_nearbyDeals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Deals Nearby',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try expanding your search radius or check back later.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _nearbyDeals.length,
            itemBuilder: (context, index) {
              final dealWithDistance = _nearbyDeals[index];
              return _buildDealItem(dealWithDistance);
            },
          ),
          if (widget.onSeeAllNearby != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: widget.onSeeAllNearby,
                icon: Icon(Icons.explore, color: AppColors.primary),
                label: Text(
                  'Explore All Nearby Deals',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDealItem(DealWithDistance dealWithDistance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.restaurant_menu,
            color: Colors.white,
          ),
        ),
        title: Text(
          dealWithDistance.deal.title,
          style: AppTextStyles.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dealWithDistance.deal.formattedDiscountedPrice,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.showDistance)
              Text(
                '${dealWithDistance.formattedDistance} • ${dealWithDistance.walkingTimeEstimate}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
          size: 16,
        ),
        onTap: () => widget.onDealTap?.call(dealWithDistance.deal),
      ),
    );
  }
  
  IconData _getLocationIcon() {
    switch (_permissionStatus) {
      case LocationPermissionStatus.granted:
        return Icons.location_on;
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
        return Icons.location_disabled;
      case LocationPermissionStatus.serviceDisabled:
        return Icons.location_off;
    }
  }
  
  String _getHeaderTitle() {
    if (_isLoading) return 'Finding Deals Near You...';
    
    switch (_permissionStatus) {
      case LocationPermissionStatus.granted:
        return _nearbyDeals.isEmpty ? 'No Deals Nearby' : 'Deals Near You';
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
        return 'Enable Location Access';
      case LocationPermissionStatus.serviceDisabled:
        return 'Location Services Off';
    }
  }
  
  String _getHeaderSubtitle() {
    if (_isLoading) return 'Locating your position...';
    
    switch (_permissionStatus) {
      case LocationPermissionStatus.granted:
        if (_nearbyDeals.isEmpty) {
          return 'Try expanding your search radius';
        } else {
          final closest = _nearbyDeals.first;
          return '${_nearbyDeals.length} deals found • Closest: ${closest.formattedDistance}';
        }
      case LocationPermissionStatus.denied:
      case LocationPermissionStatus.deniedForever:
        return 'Show food deals within walking distance';
      case LocationPermissionStatus.serviceDisabled:
        return 'Enable location services in settings';
    }
  }
}