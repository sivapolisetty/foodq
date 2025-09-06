// Example usage of UnifiedDealCard
// This file shows how to use the unified deal card component in different modes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'unified_deal_card.dart';
import '../models/deal.dart';

class UnifiedDealCardExample extends ConsumerWidget {
  final Deal sampleDeal;

  const UnifiedDealCardExample({
    super.key,
    required this.sampleDeal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnifiedDealCard Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Mode - Default vertical layout for customer browsing
            const Text(
              'Customer Mode (Vertical)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            UnifiedDealCard(
              deal: sampleDeal,
              onTap: () => _showMessage(context, 'Customer deal tapped'),
              mode: DealCardMode.customer,
              showDistance: true,
              distance: 0.5,
              showCartControls: true,
              showQuickOrder: true,
            ),
            
            const SizedBox(height: 24),
            
            // Business Mode - For business dashboard with detailed info
            const Text(
              'Business Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            UnifiedDealCard(
              deal: sampleDeal,
              onTap: () => _showMessage(context, 'Business deal tapped'),
              mode: DealCardMode.business,
              showUrgencyIndicator: true,
              showBusinessControls: true,
              showFullDetails: true,
              onEdit: () => _showMessage(context, 'Edit deal'),
              onDeactivate: () => _showMessage(context, 'Deactivate deal'),
            ),
            
            const SizedBox(height: 24),
            
            // Search Mode - Compact for search results
            const Text(
              'Search Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            UnifiedDealCard(
              deal: sampleDeal,
              onTap: () => _showMessage(context, 'Search result tapped'),
              mode: DealCardMode.search,
              isCompact: true,
              showCartControls: true,
            ),
            
            const SizedBox(height: 24),
            
            // List Mode - Horizontal layout for lists
            const Text(
              'List Mode (Horizontal)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            UnifiedDealCard(
              deal: sampleDeal,
              onTap: () => _showMessage(context, 'List item tapped'),
              mode: DealCardMode.list,
              orientation: CardOrientation.horizontal,
              showCartControls: true,
              showDistance: true,
              distance: 1.2,
            ),
            
            const SizedBox(height: 24),
            
            // Customer Mode - Horizontal layout
            const Text(
              'Customer Mode (Horizontal)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            UnifiedDealCard(
              deal: sampleDeal,
              onTap: () => _showMessage(context, 'Horizontal customer deal tapped'),
              mode: DealCardMode.customer,
              orientation: CardOrientation.horizontal,
              showCartControls: true,
              showDistance: true,
              distance: 0.8,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

/*
Usage Examples:

1. Customer browsing deals (default):
UnifiedDealCard(
  deal: deal,
  onTap: () => navigateToDealDetails(),
  mode: DealCardMode.customer,
  showDistance: true,
  distance: 0.5, // km
  showCartControls: true,
  showQuickOrder: true,
)

2. Business dashboard:
UnifiedDealCard(
  deal: deal,
  onTap: () => viewDealAnalytics(),
  mode: DealCardMode.business,
  showUrgencyIndicator: true,
  showBusinessControls: true,
  showFullDetails: true,
  onEdit: () => editDeal(),
  onDeactivate: () => deactivateDeal(),
)

3. Search results:
UnifiedDealCard(
  deal: deal,
  onTap: () => selectDeal(),
  mode: DealCardMode.search,
  isCompact: true,
  showCartControls: true,
)

4. List view:
UnifiedDealCard(
  deal: deal,
  onTap: () => viewDeal(),
  mode: DealCardMode.list,
  orientation: CardOrientation.horizontal,
  showCartControls: true,
  showDistance: true,
  distance: 1.2,
)

Key Features:
- Responsive design that adapts to different screen sizes
- Consistent theming across all modes
- Riverpod state management integration
- Cart functionality with validation
- Business controls for restaurant owners
- Distance display for location-based features
- Urgency indicators with animations
- Comprehensive deal information display
- Error handling and loading states
- Accessibility support
*/