import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/deal.dart';
import 'deal_card.dart';

class PickupSection extends StatelessWidget {
  final String title;
  final List<Deal> deals;
  final VoidCallback onViewAll;

  const PickupSection({
    Key? key,
    required this.title,
    required this.deals,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Color(0xFF4CAF50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Deals horizontal list
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == deals.length - 1 ? 0 : 16,
                ),
                child: DealCard(
                  deal: deal,
                  onTap: () => _handleDealTap(context, deal),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleDealTap(BuildContext context, Deal deal) {
    // Navigate to deal details screen
    context.go('/deal-details', extra: deal);
  }
}