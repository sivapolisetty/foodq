import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../shared/models/deal.dart';
import '../../../shared/models/food_library_item.dart';
import '../../../shared/models/app_user.dart';
import 'deal_search_modal.dart';
import 'create_deal_bottom_sheet.dart';

class EnhancedCreateDealBottomSheet extends ConsumerStatefulWidget {
  final Deal? deal; // If provided, we're editing; otherwise creating
  final AppUser? currentUser; // Pass current user to avoid provider issues

  const EnhancedCreateDealBottomSheet({
    super.key,
    this.deal,
    this.currentUser,
  });

  @override
  ConsumerState<EnhancedCreateDealBottomSheet> createState() => _EnhancedCreateDealBottomSheetState();
}

class _EnhancedCreateDealBottomSheetState extends ConsumerState<EnhancedCreateDealBottomSheet> {
  bool _showForm = false;
  Deal? _selectedDeal;
  FoodLibraryItem? _selectedFoodLibraryItem;

  @override
  void initState() {
    super.initState();
    // If editing an existing deal, go directly to form
    if (widget.deal != null) {
      _showForm = true;
    }
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DealSearchModal(
          onDealSelected: (deal) {
            Navigator.of(context).pop();
            _handleDealSelection(deal);
          },
          onFoodLibraryItemSelected: (item) {
            Navigator.of(context).pop();
            _handleFoodLibraryItemSelection(item);
          },
          onCreateCustomDeal: () {
            Navigator.of(context).pop();
            _handleCreateCustomDeal();
          },
        ),
      ),
    );
  }

  void _handleDealSelection(Deal? deal) {
    if (deal != null) {
      setState(() {
        _selectedDeal = deal;
        _showForm = true;
      });
    }
  }

  void _handleFoodLibraryItemSelection(FoodLibraryItem? item) {
    if (item != null) {
      setState(() {
        _selectedFoodLibraryItem = item;
        _showForm = true;
      });
    }
  }

  void _handleCreateCustomDeal() {
    setState(() {
      _selectedDeal = null;
      _selectedFoodLibraryItem = null;
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showForm) {
      return CreateDealBottomSheet(
        deal: _selectedDeal ?? widget.deal,
        currentUser: widget.currentUser,
        foodLibraryItem: _selectedFoodLibraryItem,
      );
    }

    // Initial search interface
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.add_business,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create New Deal',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Welcome message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Let\'s create your deal!',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll help you find existing items or create something new from scratch.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Search/Browse button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showSearchModal,
                    icon: const Icon(Icons.search),
                    label: Text(
                      'Search Existing Items',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // OR divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Create custom deal button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleCreateCustomDeal,
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Create Custom Deal',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Info section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tip',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Searching first helps avoid duplicates and saves time by using pre-filled templates from our food library.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}