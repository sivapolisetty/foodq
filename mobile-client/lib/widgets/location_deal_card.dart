import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/deal_with_distance.dart';
import '../utils/location_utils.dart';

class LocationDealCard extends StatelessWidget {
  final DealWithDistance dealWithDistance;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showDeliveryInfo;

  const LocationDealCard({
    Key? key,
    required this.dealWithDistance,
    this.onTap,
    this.showDistance = true,
    this.showDeliveryInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deal = dealWithDistance.deal;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      child: deal.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: deal.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.local_offer,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.local_offer,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  
                  // Top badges row
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Distance badge
                        if (showDistance)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  dealWithDistance.formattedDistance,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Discount badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${deal.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Delivery badge at bottom of image
                  if (showDeliveryInfo && dealWithDistance.isDeliveryAvailable)
                    Positioned(
                      bottom: 8,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDeliveryBadgeColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getDeliveryIcon(),
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dealWithDistance.deliveryStatus,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              
              // Content section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name and area
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dealWithDistance.businessName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dealWithDistance.areaName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Deal title
                    Text(
                      deal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B1B1B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    if (deal.description != null)
                      Text(
                        deal.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    
                    // Price section
                    Row(
                      children: [
                        Text(
                          '₹${deal.discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${deal.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Spacer(),
                        
                        // Delivery fee
                        if (showDeliveryInfo && dealWithDistance.isDeliveryAvailable)
                          Text(
                            dealWithDistance.deliveryFee == 0 
                                ? 'Free Delivery' 
                                : '+₹${dealWithDistance.deliveryFee.toInt()} delivery',
                            style: TextStyle(
                              fontSize: 11,
                              color: dealWithDistance.deliveryFee == 0 
                                  ? Colors.green.shade600 
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Validity and location info
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Valid until ${_formatDate(deal.validUntil)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (showDistance) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.directions_walk,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(dealWithDistance.distanceKm * 1000 / 80).ceil()} min walk',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
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

  Color _getDeliveryBadgeColor() {
    switch (dealWithDistance.deliveryZone) {
      case DeliveryZone.express:
        return Colors.green.shade600;
      case DeliveryZone.standard:
        return Colors.blue.shade600;
      case DeliveryZone.extended:
        return Colors.orange.shade600;
      case DeliveryZone.notAvailable:
        return Colors.red.shade600;
    }
  }

  IconData _getDeliveryIcon() {
    switch (dealWithDistance.deliveryZone) {
      case DeliveryZone.express:
        return Icons.flash_on;
      case DeliveryZone.standard:
        return Icons.delivery_dining;
      case DeliveryZone.extended:
        return Icons.local_shipping;
      case DeliveryZone.notAvailable:
        return Icons.block;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Compact version for list views
class CompactLocationDealCard extends StatelessWidget {
  final DealWithDistance dealWithDistance;
  final VoidCallback? onTap;

  const CompactLocationDealCard({
    Key? key,
    required this.dealWithDistance,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deal = dealWithDistance.deal;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  child: deal.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 24),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.local_offer, size: 24),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.local_offer, size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business name and distance
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dealWithDistance.businessName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            dealWithDistance.formattedDistance,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Deal title
                    Text(
                      deal.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B1B1B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Price and delivery
                    Row(
                      children: [
                        Text(
                          '₹${deal.discountedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${deal.originalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Spacer(),
                        if (dealWithDistance.isDeliveryAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: dealWithDistance.deliveryFee == 0 
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dealWithDistance.deliveryFee == 0 ? 'Free' : '₹${dealWithDistance.deliveryFee.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: dealWithDistance.deliveryFee == 0 
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Discount badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${deal.discountPercentage}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}