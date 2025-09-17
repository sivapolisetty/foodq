import 'package:flutter/material.dart';
import '../../search/services/search_service.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/widgets/deal_card.dart';

/// Enhanced deal card wrapper that displays distance information using shared DealCard
class EnhancedDealCard extends StatelessWidget {
  final DealWithDistance dealWithDistance;
  final VoidCallback? onTap;
  final bool isExpired;

  const EnhancedDealCard({
    Key? key,
    required this.dealWithDistance,
    this.onTap,
    this.isExpired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: DealCard(
        deal: dealWithDistance.deal,
        onTap: onTap ?? () {},
        showDistance: !isExpired, // Don't show distance for expired deals
        distance: dealWithDistance.distanceInMiles,
        showCartControls: !isExpired, // Don't show cart controls for expired deals
        isExpired: isExpired,
      ),
    );
  }
}