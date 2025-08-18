import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/business.dart';

class BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;
  final bool showDistance;
  final double? distance;

  const BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    this.showDistance = false,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Business Logo/Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: business.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          business.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderLogo(),
                        ),
                      )
                    : _buildPlaceholderLogo(),
              ),

              const SizedBox(width: 16),

              // Business Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Name
                    Text(
                      business.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    if (business.category != null)
                      Text(
                        business.category!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Rating and Reviews
                    Row(
                      children: [
                        if (business.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            business.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          business.reviewText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Address and Distance/Active Deals
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.displayAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showDistance && distance != null)
                          _buildDistanceInfo()
                        else if (business.activeDeals > 0)
                          _buildActiveDealsInfo(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderLogo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.primaryGreen.withOpacity(0.1),
      ),
      child: Icon(
        Icons.restaurant,
        size: 32,
        color: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildDistanceInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 12,
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            distance! < 1
                ? '${(distance! * 1000).round()}m'
                : '${distance!.toStringAsFixed(1)}km',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDealsInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${business.activeDeals} deal${business.activeDeals == 1 ? '' : 's'}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.accentOrange,
        ),
      ),
    );
  }
}